# frozen_string_literal: true

class Signup < ApplicationRecord
  encrypts :fakepay_token

  validates :name, :plan, presence: true
  validates :plan, inclusion: { in: %w[bronze_box silver_box gold_box] }

  belongs_to :shipping_address, class_name: 'Address'

  def set_next_charge_date
    if next_charge_date.nil?
      next_charge_date = TimeHelper.same_day_next_month(created_at)
    elsif next_charge_date > Date.today
      # do nothing
    else
      next_charge_date = TimeHelper.same_day_next_month(next_charge_date)
    end
  end
end
