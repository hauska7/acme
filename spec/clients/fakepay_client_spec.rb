# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FakePayClient do
  describe '#first_charge' do
    subject { described_class.new(api_key).first_charge(payload) }

    let(:api_key) { Rails.application.credentials.fakepay_api_key_test }
    let(:payload) do
      { amount: '1000',
        card_number:,
        cvv: '123',
        expiration_month: '01',
        expiration_year: Date.current.year + 2,
        zip_code: '10045' }
    end
    let(:card_number) { '4242424242424242' }

    context 'when request is correct' do
      it 'creates charge' do
        result = subject

        expect(result[:success]).to be true
        expect(result[:token]).to be_present
      end
    end

    context 'when card number is invalid' do
      let(:card_number) { '4242424242424241' }

      it 'response contains fakepay errors' do
        result = subject

        expect(result[:success]).to be false
        expect(result[:error_code]).to eq 'fakepay_error'
        expect(result[:fakepay_error_code]).to be_present
        expect(result[:fakepay_error_message]).to be_present
      end
    end

    context 'when credentials are invalid' do
      let(:api_key) { 'invalid' }

      it 'response contains error' do
        result = subject

        expect(result[:success]).to be false
        expect(result[:error_code]).to eq 'invalid_credentials'
      end
    end

    context 'when there is a network issue' do
      before { raise }

      it 'response contains error' do
        result = subject

        expect(result[:success]).to be false
        expect(result[:error_code]).to eq 'network_issue'
      end
    end
  end
end
