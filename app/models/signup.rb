class Signup < ApplicationRecord
  encrypts :fakepay_token

  enum plan: ['bronze_box', 'silver_box', 'gold_box']

  validates :name, :plan, presence: true
  validates :plan, inclusion: { in: plans.keys }
end
