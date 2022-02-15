# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address do
  context 'with correct data' do
    it 'saves' do
      address = described_class.new
      address.street = 'Sesame Street'
      address.city = 'New York'
      address.zip_code = '11111'
      address.country = 'USA'

      expect(address.save).to be true
    end
  end
end
