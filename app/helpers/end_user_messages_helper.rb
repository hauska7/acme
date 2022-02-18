# frozen_string_literal: true

# Provide end user messages for different situations
module EndUserMessagesHelper
  # Messages documentation: https://www.fakepay.io/
  FAKEPAY_ERROR_MESSAGES = {
    '1000001' => { message: 'Invalid credit card number',
                   fields: ['billing/card_number'] },
    '1000002' => { message: 'Insufficient funds' },
    '1000003' => { message: 'CVV failure', fields: ['billing/cvv'] },
    '1000004' => { message: 'Expired card',
                   fields: ['billing/expiration_month', 'billing/expiration_year'] },
    '1000005' => { message: 'Invalid zip code', fields: ['billing/zip_code'] }
  }
                           .symbolize_keys

  def self.fakepay_error_with_notification(error_code)
    fakepay_error(error_code, notify_missing_codes: true)
  end

  def self.fakepay_error(error_code, notify_missing_codes: false)
    result = FAKEPAY_ERROR_MESSAGES[error_code.to_s.to_sym]
    if result.nil?
      if notify_missing_codes
        NotifyDevelopersService.notify(issue: 'unknown_fakepay_error_code', fakepay_error_code: error_code)
      end

      result = { message: 'Problem with payment.' }
    end

    result
  end

  # rubocop:disable Style/IdenticalConditionalBranches
  # rubocop:disable Lint/DuplicateBranch
  def self.acme_error(error_code)
    if error_code == 'server_error'
      { message: 'There is a problem. Try again later.' }
    else
      { message: 'There is a problem. Try again later.' }
    end
  end
  # rubocop:enable Lint/DuplicateBranch
  # rubocop:enable Style/IdenticalConditionalBranches
end
