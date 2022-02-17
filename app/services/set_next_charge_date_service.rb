# frozen_string_literal: true

# Set next charge date
module SetNextChargeDateService
  def self.call(signup)
    if signup.next_charge_date.nil?
      return unless signup.created_at

      signup.next_charge_date = 1.month.since signup.created_at.to_date
    elsif signup.next_charge_date < Date.tomorrow
      signup.next_charge_date = 1.month.since signup.next_charge_date
    end
  end
end
