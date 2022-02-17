# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RenewSubscriptionsService do
  let(:subscription) { create(:subscription, fakepay_token: '7777', next_charge_date: Date.today - 1) }
  let(:no_token_subscription) { create(:subscription, fakepay_token: nil, next_charge_date: Date.today - 1) }
  let(:not_scheduled_subscription) { create(:subscription, fakepay_token: '6666', next_charge_date: Date.today + 1) }
  let(:fakepay_client) { instance_double(FakepayClient) }
  let(:mock_fakepay_client) do
    allow(FakepayClient).to receive(:new).and_return(fakepay_client)
    allow(fakepay_client).to receive(:subsequent_charge).with(
      amount_cents: 1999,
      token: '7777'
    ).and_return(fakepay_result)
  end
  let(:fakepay_result) { nil }

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

  before { mock_fakepay_client }

  context 'when there are subscriptions to renew' do
    before { subscription }

    context 'when there are subscriptions that cant be renewed due to lack of token' do
      before { no_token_subscription }

      context 'when there are subscriptions that should not be renewed due to subscription date' do
        before { not_scheduled_subscription }

        context 'when fakepay client succeeds' do
          let(:fakepay_result) { { success: true, token: 'new_token' } }

          it 'renews qualified subscriptions' do
            expect(fakepay_client).to receive(:subsequent_charge).with(token: '7777', amount_cents: 1999).once

            described_class.call

            old_next_charge_date = subscription.next_charge_date
            subscription.reload

            expect(subscription.next_charge_date > old_next_charge_date)
            expect(subscription.fakepay_token).to eq 'new_token'
          end
        end

        context 'when fakepay client returns invalid_credentials error' do
          let(:fakepay_result) { { success: false, error_code: 'invalid_credentials' } }

          it 'doesnt change subscription next_charge_date' do
            expect(NotifyDevelopersService)
              .to receive(:notify)
              .with(hash_including(issue: 'fakepay_invalid_credentials'))
              .once

            described_class.call

            old_next_charge_date = subscription.next_charge_date
            subscription.reload

            expect(subscription.next_charge_date).to eq old_next_charge_date
          end
        end

        context 'when fakepay client returns server_error error' do
          let(:fakepay_result) { { success: false, error_code: 'server_error' } }

          it 'raises repeat error' do
            expect { described_class.call }.to raise_error(RenewSubscriptionsService::RepeatError)

            old_next_charge_date = subscription.next_charge_date
            subscription.reload

            expect(subscription.next_charge_date).to eq old_next_charge_date
          end
        end

        context 'when fakepay client returns network_issue error' do
          let(:fakepay_result) { { success: false, error_code: 'network_issue' } }

          it 'raises repeat error' do
            expect { described_class.call }.to raise_error(RenewSubscriptionsService::RepeatError)

            old_next_charge_date = subscription.next_charge_date
            subscription.reload

            expect(subscription.next_charge_date).to eq old_next_charge_date
          end
        end

        context 'when fakepay client returns unexpected error' do
          let(:fakepay_result) { { success: false, error_code: 'unexpected' } }

          it 'raises repeat error' do
            expect(NotifyDevelopersService)
              .to receive(:notify)
              .with(hash_including(issue: 'unexpected_fakepay_error'))
              .once

            described_class.call

            old_next_charge_date = subscription.next_charge_date
            subscription.reload

            expect(subscription.next_charge_date).to eq old_next_charge_date
          end
        end
      end
    end
  end
end
