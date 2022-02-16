# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SignupsController, type: :controller do
  describe '#create' do
    let(:params) do
      { name: 'Johny Bravo',
        plan: 'bronze_box',
        shipping_address: {
          street: 'Sesame Street',
          city: 'New York',
          zip_code: '11111',
          country: 'USA'
        },
        billing: {
          card_number: '4242424242424242',
          cvv: '123',
          expiration_month: '02',
          expiration_year: Date.current.year + 2,
          zip_code: '22222'
        } }
    end

    context 'with fakepay call' do
      let(:fakepay_client) { instance_double(FakepayClient) }
      before do
        allow(FakepayClient).to receive(:new).and_return(fakepay_client)
        allow(fakepay_client).to receive(:first_charge).with(
          amount_cents: 1999,
          card_number: '4242424242424242',
          cvv: '123',
          expiration_month: '02',
          expiration_year: (Date.current.year + 2).to_s,
          zip_code: '22222'
        ).and_return(fakepay_result)
      end

      context 'when request is valid' do
        context 'when fakepay is successful' do
          let(:fakepay_result) do
            { success: true,
              token: '9674' }
          end

          it 'creates a signup' do
            expect(fakepay_client).to receive(:first_charge).once

            expect do
              post :create, params: params
            end.to change { Signup.count }.by 1

            signup = Signup.last
            expect(signup.name).to eq 'Johny Bravo'
            expect(signup.plan).to eq 'bronze_box'
            expect(signup.fakepay_token).to eq '9674'
            address = signup.shipping_address
            expect(address.street).to eq 'Sesame Street'
            expect(address.city).to eq 'New York'
            expect(address.zip_code).to eq '11111'
            expect(address.country).to eq 'USA'

            expect(response).to have_http_status(201)
            parsed_response = JSON.parse response.body
            expect(parsed_response['signup_id']).to eq signup.id
          end
        end

        context 'when fakepay credentials are invalid' do
          let(:fakepay_result) do
            { success: false,
              error_code: 'invalid_credentials' }
          end

          it 'returns error information' do
            expect do
              post :create, params:
            end.not_to change { Signup.count }

            expect(response).to have_http_status(503)
            parsed_response = JSON.parse response.body
            expect(parsed_response['error_code']).to eq 'server_error'
            expect(parsed_response['error_message']).to be_present
            expect(parsed_response['error_fields']).to be_nil
          end
        end

        context 'when fakepay responds with server error' do
          let(:fakepay_result) do
            { success: false,
              error_code: 'server_error' }
          end

          it 'returns error information' do
            expect do
              post :create, params: params
            end.not_to change { Signup.count }

            expect(response).to have_http_status(503)
            parsed_response = JSON.parse response.body
            expect(parsed_response['error_code']).to eq 'server_error'
            expect(parsed_response['error_message']).to be_present
            expect(parsed_response['error_fields']).to be_nil
          end
        end

        context 'when fakepay network connection fails' do
          let(:fakepay_result) do
            { success: false,
              error_code: 'network_issue' }
          end

          it 'returns error information' do
            expect do
              post :create, params: params
            end.not_to change { Signup.count }

            expect(response).to have_http_status(503)
            parsed_response = JSON.parse response.body
            expect(parsed_response['error_code']).to eq 'server_error'
            expect(parsed_response['error_message']).to be_present
            expect(parsed_response['error_fields']).to be_nil
          end
        end
      end

      context 'when request is invalid' do
        context 'when fakepay validation fails' do
          let(:fakepay_result) do
            { success: false,
              error_code: 'validation_error',
              fakepay_error_code: fakepay_error_code }
          end

          context 'when fakepay error code is known' do
            let(:fakepay_error_code) { '1000001' }

            it 'returns error information' do
              expect do
                post :create, params: params
              end.not_to change { Signup.count }

              expect(response).to have_http_status(422)
              parsed_response = JSON.parse response.body
              expect(parsed_response['error_code']).to eq 'fakepay_validation_error'
              expect(parsed_response['error_message']).to eq 'Invalid credit card number'
              expect(parsed_response['error_fields']).to eq ['billing/card_number']
            end
          end

          context 'when fakepay error code is not known' do
            let(:fakepay_error_code) { '1111' }

            it 'returns error information' do
              expect(NotifyDevelopersService)
                .to receive(:notify)
                .with(fakepay_error_code: "1111", issue: "unknown_fakepay_error_code")
                .once

              expect do
                post :create, params: params
              end.not_to change { Signup.count }

              expect(response).to have_http_status(422)
              parsed_response = JSON.parse response.body
              expect(parsed_response['error_code']).to eq 'fakepay_validation_error'
              expect(parsed_response['error_message']).to eq 'Problem with payment.'
              expect(parsed_response['error_fields']).to be_nil
            end
          end
        end
      end
    end

    context 'when request is invalid' do
      before { params[:shipping_address][:zip_code] = nil }

      it 'returns error information' do
        expect do
          post :create, params: params
        end.not_to change { Signup.count }

        expect(response).to have_http_status(422)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error_code']).to eq 'validation_failed'
        expect(parsed_response['error_message']).to eq 'Shipping zip code is invalid.'
        expect(parsed_response['error_fields']).to eq ['shipping/zip_code']
      end
    end
  end
end
