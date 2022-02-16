# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateSignupValidator do
  let(:params) do
    { name: 'Johny Bravo',
      plan: 'bronze_box',
      shipping_address: {
        street: 'Sesame Street',
        city: 'New York',
        zip_code: '11111',
        country: 'USA'
      },
      billing: {
        card_number: '4242424242424242',
        cvv: '123',
        expiration_month: '02',
        expiration_year: Date.current.year + 2,
        zip_code: '22222'
      } }
  end

  context 'with correct params' do
    it 'passes successfuly' do
      result = described_class.call(params)

      expect(result).to be_empty
    end
  end

  context 'with invalid params' do
    before { params[:shipping_address][:zip_code] = nil }

    it 'returns errors' do
      result = described_class.call(params)

      expect(result.first[:message]).to be_present
      expect(result.first[:api_v1_fields]).to be_present
    end
  end
end
