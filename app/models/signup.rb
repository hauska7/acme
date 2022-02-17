# frozen_string_literal: true

class Signup < ApplicationRecord
  encrypts :fakepay_token

  validates :name, :plan, presence: true
  validates :plan, inclusion: { in: %w[bronze_box silver_box gold_box] }

  belongs_to :shipping_address, class_name: 'Address'

  def set_next_charge_date
    if next_charge_date.nil?
      return unless created_at

      next_charge_date = 1.month.since created_at.to_date
    elsif next_charge_date < Date.tomorrow
      next_charge_date = 1.month.since next_charge_date
    end
  end
end
