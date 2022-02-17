# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription do
  context 'with correct data' do
    it 'saves' do
      address = create(:address)

      subscription = described_class.new
      subscription.shipping_address = address
      subscription.name = 'Johny Bravo'
      subscription.plan = 'bronze_box'
      subscription.fakepay_token = '1234'

      expect(subscription.save).to be true
    end
  end
end
