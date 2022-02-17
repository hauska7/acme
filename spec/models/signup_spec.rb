# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Signup do
  context 'with correct data' do
    it 'saves' do
      address = create(:address)

      signup = described_class.new
      signup.shipping_address = address
      signup.name = 'Johny Bravo'
      signup.plan = 'bronze_box'
      signup.fakepay_token = '1234'

      expect(signup.save).to be true
    end
  end
end
