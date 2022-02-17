# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetNextChargeDateService do
  describe '#set_next_charge_date' do
    context 'when next_charge_date is nil' do
      it 'sets next charge date' do
        signup = create(:signup, next_charge_date: nil)

        described_class.call(signup)

        expect(signup.next_charge_date).to be_present
      end
    end

    context 'when next_charge_date is in the future' do
      it 'does not change next charge date' do
        signup = create(:signup, next_charge_date: Date.tomorrow)

        expect do
          described_class.call(signup)
        end.not_to(change { signup.next_charge_date })
      end
    end

    context 'when next_charge_date is not in the future' do
      it 'sets next charge date in the furure' do
        old_next_charge_date = Date.today
        signup = create(:signup, next_charge_date: old_next_charge_date)

        described_class.call(signup)

        expect(signup.next_charge_date > old_next_charge_date).to be true
      end
    end
  end
end
