# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Signup do
  context 'with correct data' do
    it 'saves' do
      address = Address.new
      address.street = 'Sesame Street'
      address.city = 'New York'
      address.zip_code = '11111'
      address.country = 'USA'
      address.save!

      signup = described_class.new
      signup.shipping_address = address
      signup.name = 'Johny Bravo'
      signup.plan = 'bronze_box'
      signup.fakepay_token = '1234'

      expect(signup.save).to be true
    end
  end
end
