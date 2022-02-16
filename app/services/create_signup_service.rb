# frozen_string_literal: true

# Main service responsible for creating signups
module CreateSignupService
  def self.call(params)
    errors = CreateSignupValidator.call(params)
    return { status: 'validation_failed', errors: } if errors.present?

    plan_price_cents = PlanPriceService.call(params['plan'])

    fakepay_data = {
      amount_cents: plan_price_cents,
      card_number: params['billing']['card_number'],
      cvv: params['billing']['cvv'],
      expiration_month: params['billing']['expiration_month'],
      expiration_year: params['billing']['expiration_year'],
      zip_code: params['billing']['zip_code']
    }
    fakepay_result = FakepayClient.build.first_charge(fakepay_data)

    if fakepay_result[:success]
      signup = nil
      ActiveRecord::Base.transaction do
        address = Address.new
        address.street = params['shipping_address']['street']
        address.city = params['shipping_address']['city']
        address.zip_code = params['shipping_address']['zip_code']
        address.country = params['shipping_address']['country']
        address.save!

        signup = Signup.new
        signup.shipping_address = address
        signup.name = params['name']
        signup.plan = params['plan']
        signup.fakepay_token = fakepay_result[:token]
        signup.save!
      end

      { status: 'success', signup: }
    else
      case fakepay_result[:error_code]
      when 'validation_error'
        end_user_error = EndUserMessagesHelper.fakepay_error_with_notification(
          fakepay_result[:fakepay_error_code]
        )

        { status: 'fakepay_failed', fakepay_result:, errors: [end_user_error] }
      else
        { status: 'fakepay_failed', fakepay_result: }
      end
    end
  end
end
