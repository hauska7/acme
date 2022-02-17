FactoryBot.define do
  factory :signup do
    name { 'Johny Bravo' }
    plan { 'bronze_box' }
    fakepay_token { '7539' }
    shipping_address factory: :address
  end
end
