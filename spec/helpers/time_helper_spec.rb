# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeHelper do
  describe '.same_day_next_month' do
    context 'for 1 January' do
      it 'returns 1 February' do
        1_january = Date.parse('01-01-2022')

        result = described_class.call(1_january)

        expect(result).to eq Date.parse('01-02-2022')
      end
    end

    context 'for 31 January' do
      it 'returns last February' do
        31_january = Date.parse('31-01-2022')

        result = described_class.call(31_january)

        expect(result).to eq Date.parse('28-02-2022')
      end
    end

    context 'for 28 February' do
      it 'returns 28 in March' do
        28_february = Date.parse('28-02-2022')

        result = described_class.call(28_february)

        expect(result).to eq Date.parse('28-03-2022')
      end
    end
  end
end
