# frozen_string_literal: true

# Set next charge date
module SetNextChargeDateService
  # When date cant be set
  class CantError < StandardError
    attr_reader :subscription

    def initialize(msg, subscription)
      @subscription = subscription
      super(msg)
    end
  end

  def self.call!(subscription)
    result = call(subscription)
    raise CantError.new('Cant set next charge date', subscription) unless result[:success]

    result
  end

  def self.call(subscription)
    if subscription.next_charge_date.nil?
      return { success: false } unless subscription.created_at

      subscription.next_charge_date = 1.month.since subscription.created_at.to_date
    else
      subscription.next_charge_date = 1.month.since subscription.next_charge_date
    end

    { success: true }
  end
end
