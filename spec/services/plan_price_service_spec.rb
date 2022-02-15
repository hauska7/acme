# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlanPriceService do
  context 'with bronze box plan' do
    it 'returns amount in cents' do
      result = described_class.call('bronze_box')

      expect(result).to eq 1999
    end
  end

  context 'with silver box plan' do
    it 'returns amount in cents' do
      result = described_class.call('silver_box')

      expect(result).to eq 4900
    end
  end

  context 'with gold box plan' do
    it 'returns amount in cents' do
      result = described_class.call('gold_box')

      expect(result).to eq 9900
    end
  end

  context 'with invalid box plan' do
    it 'returns amount in cents' do
      result = described_class.call('silver_box')

      expect(result).to be_nil
    end
  end

  context 'with nil box plan' do
    it 'returns amount in cents' do
      result = described_class.call('silver_box')

      expect(result).to be_nil
    end
  end
end
