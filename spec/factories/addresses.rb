# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    street { 'Sesame Street' }
    city { 'New York' }
    zip_code { '90201' }
    country { 'USA' }
  end
end
