# frozen_string_literal: true

class Subscription < ApplicationRecord
  encrypts :fakepay_token

  validates :name, :plan, presence: true
  validates :plan, inclusion: { in: %w[bronze_box silver_box gold_box] }

  belongs_to :shipping_address, class_name: 'Address'
end
