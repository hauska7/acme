# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    name { 'Johny Bravo' }
    plan { 'bronze_box' }
    fakepay_token { '7539' }
    shipping_address factory: :address
  end
end
