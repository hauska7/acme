module EndUserMessagesHelper
  # Messages documentation: https://www.fakepay.io/
  FakepayErrorMessages = {
    '1000001' => { message: 'Invalid credit card number',
                   api_v1_fields: ['billing/card_number'] },
    '1000002' => { message: 'Insufficient funds', api_v1_fields: nil },
    '1000003' => { message: 'CVV failure', api_v1_fields: ['billing/cvv'] },
    '1000004' => { message: 'Expired card',
                   api_v1_fields: ['billing/expiration_month', 'billing/expiration_year'] },
    '1000005' => { message: 'Invalid zip code', api_v1_fields: ['billing/zip_code'] } }
    .symbolize_keys

  def self.fakepay_error_with_notification(error_code)
    fakepay_error(error_code, true)
  end

  def self.fakepay_error(error_code, notify_missing_codes = false)
    result = FakepayErrorMessages[error_code.to_sym]
    if result.nil?
      if notify_missing_codes
        NotifyDevelopersService.notify(issue: 'unknown_fakepay_error_code', fakepay_error_code: error_code)
      end

      result = { message: 'Problem with payment.', api_v1_fields: nil }
    end

    result
  end

  def self.acme_error(error_code)
    if error_code == 'server_error'
      { message: 'There is a problem. Try again later.' }
    else
      { message: 'There is a problem. Try again later.' }
    end
  end
end
