class Signup < ApplicationRecord
  encrypts :fakepay_token

  validates :name, :plan, presence: true
  validates :plan, inclusion: { in: ['bronze_box', 'silver_box', 'gold_box'] }

  belongs_to :shipping_address, class_name: 'Address'
end
