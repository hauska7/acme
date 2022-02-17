# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Signup do
  context 'with correct data' do
    it 'saves' do
      address = create!(:address)

      signup = described_class.new
      signup.shipping_address = address
      signup.name = 'Johny Bravo'
      signup.plan = 'bronze_box'
      signup.fakepay_token = '1234'

      expect(signup.save).to be true
    end
  end

  describe '.set_next_charge_date' do
    context 'when next_charge_date is nil' do
      it 'sets next charge date' do
        signup = create!(:signup, next_charge_date: nil)

        signup.set_next_charge_date

        expect(signup.next_charge_date).to be_present
      end
    end

    context 'when next_charge_date is in the future' do
      it 'does not change next charge date' do
        signup = create!(:signup, next_charge_date: Date.tomorrow)

        expect do
          signup.set_next_charge_date
        end.not_to(change { signup.next_charge_date })
      end
    end

    context 'when next_charge_date is not in the future' do
      it 'sets next charge date in the furure' do
        old_next_charge_date = Date.today
        signup = create!(:signup, next_charge_date: old_next_charge_date)

        signup.set_next_charge_date

        expect(signup.next_charge_date > old_next_charge_date).to be true
      end
    end
  end
end
