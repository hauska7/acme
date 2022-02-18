# frozen_string_literal: true

# Renew subscriptions
# This approach uses SELECT FOR UPDATE SKIP LOCKED so that if multiple processes are run in parallel
# they dont block each other on database call. A SELECT FOR UPDATE is later used to make sure that
# no subscriptions are skipped. A downside to this approach is that a subscription is being lock for update
# for the duration of api call.
class RenewSubscriptionsService
  class RepeatError < StandardError; end

  def self.call
    new.call
  end

  def call
    @until_date = Date.tomorrow

    loop do
      ActiveRecord::Base.transaction do
        @subscription = find_subscription
        break unless @subscription

        plan_price_cents = PlanPriceService.call(@subscription.plan)

        fakepay_data = {
          amount_cents: plan_price_cents,
          token: @subscription.fakepay_token
        }
        fakepay_result = FakepayClient.build.subsequent_charge(fakepay_data)

        if fakepay_result[:success]
          @subscription.fakepay_token = fakepay_result[:token]
          SetNextChargeDateService.call!(@subscription)
          @subscription.save!
        else
          case fakepay_result[:error_code]
          when 'invalid_token'
            @subscription.fakepay_token = nil
            @subscription.save!
          when 'invalid_credentials'
            NotifyDevelopersService.notify(issue: 'fakepay_invalid_credentials', fakepay_result:)
            return
          when 'server_error', 'network_issue'
            raise RepeatError, "fakepay_#{fakepay_result[:error_code]}"
          else
            NotifyDevelopersService.notify(issue: 'unexpected_fakepay_error', fakepay_result:)
            return
          end
        end
      end

      break unless @subscription
    end
  end

  private

  def find_subscription
    result = Subscription
             .where('next_charge_date < ?', @until_date)
             .where.not(fakepay_token: nil)
             .lock('FOR UPDATE SKIP LOCKED')
             .first

    return result if result

    Subscription
      .where('next_charge_date < ?', @until_date)
      .where.not(fakepay_token: nil)
      .lock('FOR UPDATE')
      .first
  end
end
