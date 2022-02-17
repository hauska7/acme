# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetNextChargeDateService do
  describe '.call' do
    context 'when next_charge_date is nil and created_at is nil' do
      it 'sets next charge date' do
        signup = build(:signup, next_charge_date: nil)

        result = described_class.call(signup)

        expect(result[:success]).to be false
        expect(signup.next_charge_date).to be_nil
      end
    end

    context 'when next_charge_date is nil' do
      it 'sets next charge date' do
        signup = create(:signup, next_charge_date: nil)

        result = described_class.call(signup)

        expect(result[:success]).to be true
        expect(signup.next_charge_date).to be_present
      end
    end

    context 'when next_charge_date is present' do
      it 'sets next charge date in the future' do
        old_next_charge_date = Date.today
        signup = create(:signup, next_charge_date: old_next_charge_date)

        result = described_class.call(signup)

        expect(result[:success]).to be true
        expect(signup.next_charge_date > old_next_charge_date).to be true
      end
    end
  end

  describe '.call!' do
    context 'when next_charge_date is nil and created_at is nil' do
      it 'raises error' do
        signup = build(:signup, next_charge_date: nil)

        expect { described_class.call!(signup) }.to raise_error(SetNextChargeDateService::CantError)
      end
    end

    context 'when next_charge_date is present' do
      it 'returns successfuly' do
        signup = create(:signup, next_charge_date: Date.today)

        result = described_class.call!(signup)

        expect(result[:success]).to be true
      end
    end
  end
end
