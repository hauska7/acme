# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RenewSubscriptionsService do
  let(:subscription) { create(:signup, fakepay_token: '7777', next_charge_date: Date.today - 1) }
  let(:no_token_subscription) { create(:signup, fakepay_token: nil, next_charge_date: Date.today - 1) }
  let(:not_scheduled_subscription) { create(:signup, fakepay_token: '6666', next_charge_date: Date.today + 1) }
  let(:fakepay_client) { instance_double(FakepayClient) }

  before { allow(FakepayClient).to receive(:new).and_return(fakepay_client) }

  context 'when there is no subscriptions to renew' do
    context 'when there are subscriptions that cant be renewed due to lack of token' do
      before { no_token_subscription }

      context 'when there are subscriptions that should not be renewed due to subscription date' do
        before { not_scheduled_subscription }

        it 'does not process any subscriptions' do
          expect(fakepay_client).to receive(:subsequent_charge).exactly(0).times

          described_class.call
        end
      end
    end
  end

  context 'when there are subscriptions to renew' do
    before { subscription }

    context 'when there are subscriptions that cant be renewed due to lack of token' do
      before { no_token_subscription }

      context 'when there are subscriptions that should not be renewed due to subscription date' do
        before { not_scheduled_subscription }

        it 'renews qualified subscriptions' do
          expect(fakepay_client).to receive(:subsequent_charge).with(token: '7777', amount_cents: 1999).once

          described_class.call
        end
      end
    end
  end
end
