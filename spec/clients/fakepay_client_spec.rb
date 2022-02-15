# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FakepayClient do
  describe '.build' do
    it 'builds fakepay client' do
      result = described_class.build

      expect(result.api_key).to be_present
    end
  end

  describe '#first_charge' do
    subject { described_class.new(api_key).first_charge(payload) }

    let(:api_key) { Rails.application.credentials.fakepay_api_key_test }
    let(:payload) do
      { amount_cents: '1000',
        card_number:,
        cvv: '123',
        expiration_month: '01',
        expiration_year: Date.current.year + 2,
        zip_code: '10045' }
    end
    let(:card_number) { '4242424242424242' }

    context 'when request is correct' do
      it 'creates charge' do
        result = nil
        VCR.use_cassette('fakepay_correct') do
          result = subject
        end

        expect(result[:success]).to be true
        expect(result[:token]).to be_present
      end
    end

    context 'when card number is invalid' do
      let(:card_number) { '4242424242424241' }

      it 'response contains fakepay errors' do
        result = nil
        VCR.use_cassette('fakepay_invalid') do
          result = subject
        end

        expect(result[:success]).to be false
        expect(result[:error_code]).to eq 'fakepay_validation_error'
        expect(result[:fakepay_error_code]).to be_present
      end
    end

    context 'when card number is missing' do
      let(:card_number) { nil }

      it 'response contains fakepay errors' do
        result = nil
        VCR.use_cassette('fakepay_missing') do
          result = subject
        end

        expect(result[:success]).to be false
        expect(result[:error_code]).to eq 'fakepay_validation_error'
        expect(result[:fakepay_error_code]).to be_present
      end
    end

    context 'when credentials are invalid' do
      let(:api_key) { 'invalid' }

      it 'response contains error' do
        result = nil
        VCR.use_cassette('fakepay_unauthorized') do
          result = subject
        end

        expect(result[:success]).to be false
        expect(result[:error_code]).to eq 'invalid_credentials'
      end
    end

    context 'when fakepay returns 500' do
      let(:server_failure_response) { double(code: '500') }

      before { allow(Net::HTTP).to receive(:post).and_return(server_failure_response) }

      it 'response contains error' do
        result = subject

        expect(result[:success]).to be false
        expect(result[:error_code]).to eq 'fakepay_serious_error'
      end
    end

    context 'when there is a network issue' do
      before { allow(Net::HTTP).to receive(:post).and_raise(Timeout::Error) }

      it 'response contains error' do
        result = subject

        expect(result[:success]).to be false
        expect(result[:error_code]).to eq 'network_issue'
      end
    end
  end
end
