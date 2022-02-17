# frozen_string_literal: true

module Api
  module V1
    # Subscriptions Controller
    class SubscriptionsController < ApplicationController
      def create
        result = CreateSubscriptionService.call(params)

        case result[:status]
        when 'success'
          render status: 201, json: { subscription_id: result[:subscription].id }
        when 'validation_failed'
          render status: 422, json: { error_code: 'validation_failed', errors: result[:errors] }
        when 'fakepay_failed'
          case result[:fakepay_result][:error_code]
          when 'validation_error'
            render status: 422, json: { error_code: 'fakepay_validation_error',
                                        errors: result[:errors] }
          when 'invalid_credentials', 'server_error', 'network_issue'
            NotifyDevelopersService.notify(issue: "fakepay_#{result[:fakepay_result][:error_code]}")

            end_user_message = EndUserMessagesHelper.acme_error('server_error')

            render status: 503, json: { error_code: 'server_error',
                                        errors: [{ message: end_user_message }] }
          end
        end
      end
    end
  end
end
