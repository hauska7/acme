# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EndUserMessagesHelper do
  describe '.fakepay_error' do
    context 'known error' do
      it 'returns error message and fields' do
        result = described_class.fakepay_error('1000001')

        expect(result[:message]).to eq 'hello'
        expect(result[:fields]).to eq ['hello']
      end
    end

    context 'unknown error' do
      it 'returns error message' do
        result = described_class.fakepay_error('unknown')

        expect(result[:message]).to eq 'hello'
        expect(result[:fields]).to be_nil
      end
    end
  end

  describe '.fakepay_error_with_notification' do
    context 'known error' do
      it 'doesnt notify developers' do
        expect(NotifyDevelopers).not_to receive(:notify)

        result = described_class.fakepay_error_with_notification('1000001')

        expect(result[:message]).to eq 'hello'
        expect(result[:fields]).to eq ['hello']
      end
    end

    context 'unknown error' do
      it 'notifies developers' do
        allow(NotifyDevelopers)
          .to receive(:notify)
          .with(issue: 'unknown_fakepay_error_code', fakepay_error_code: 'unknown')
        expect(NotifyDevelopers).to receive(:notify).once

        result = described_class.fakepay_error_with_notification('unknown')

        expect(result[:message]).to eq 'hello'
        expect(result[:fields]).to be_nil
      end
    end
  end

  describe '.acme_error' do
    context 'known error' do
      it 'returns error message' do
        result = described_class.acme_error('server_error')

        expect(result[:message]).to eq 'hello'
      end
    end

    context 'unknown error' do
      it 'returns error message' do
        result = described_class.acme_error('unknown')

        expect(result[:message]).to eq 'hello'
      end
    end
  end
end
