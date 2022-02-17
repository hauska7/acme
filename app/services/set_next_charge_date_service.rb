# frozen_string_literal: true

# Set next charge date
module SetNextChargeDateService
  # When date cant be set
  class CantError < StandardError
    attr_reader :signup

    def initialize(msg, signup)
      @signup = signup
      super(msg)
    end
  end

  def self.call!(signup)
    result = call(signup)
    raise CantError.new('Cant set next charge date', signup) unless result[:success]

    result
  end

  def self.call(signup)
    if signup.next_charge_date.nil?
      return { success: false } unless signup.created_at

      signup.next_charge_date = 1.month.since signup.created_at.to_date
    else
      signup.next_charge_date = 1.month.since signup.next_charge_date
    end

    { success: true }
  end
end
