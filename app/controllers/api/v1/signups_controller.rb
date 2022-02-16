class Api::V1::SignupsController < ApplicationController
  def create
    result = CreateSignupService.call(params)

    case result[:status]
    when 'success'
      render status: 201, json: { signup_id: result[:signup].id }
    when 'validation_failed'
      # this flow can be ignored as per assignment instructions
    when 'fakepay_failed'
      case result[:fakepay_result][:error_code]
      when 'validation_error'
        end_user_error = EndUserMessagsHelper.fakepay_error_with_notification(
          result[:fakepay_result][:fakepay_error_code]
          )

        render status: 422, json: { error_code: 'fakepay_validation_error',
                                    error_message: end_user_error[:message],
                                    error_fields: end_user_error[:fields] }
      when 'invalid_credentials'
        render status: 503, json: { error_code: 'server_error',
                                    error_message: end_user_error_message_acme('server_error') }
      when 'server_error'
        render status: 503, json: { error_code: 'server_error',
                                    error_message: end_user_error_message_acme('server_error') }
      when 'network_issue'
        render status: 503, json: { error_code: 'server_error',
                                    error_message: end_user_error_message_acme('server_error') }
      end
    end
  end

  private

  def end_user_message_acme(error_code)
    EndUserMessagesHelper.acme_error(error_code)
  end
end
