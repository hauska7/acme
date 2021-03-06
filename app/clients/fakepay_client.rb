# frozen_string_literal: true

require 'net/http'

# Api client for Fakepay
class FakepayClient
  def self.build
    api_key = Rails.application.credentials.send("fakepay_api_key_#{Rails.env}")
    new(api_key)
  end

  def self.net_http_errors
    [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
     Net::HTTPHeaderSyntaxError, Net::ProtocolError]
  end

  def initialize(api_key)
    @api_key = api_key
    @uri = URI('https://www.fakepay.io/purchase')
  end

  attr_reader :api_key

  def first_charge(data)
    payload = data.except(:amount_cents)
    payload[:amount] = data[:amount_cents]
    payload = payload.transform_values(&:to_s).to_json

    response = Net::HTTP.post @uri, payload, headers

    case response.code
    when '200'
      body = JSON.parse response.body

      { success: true,
        token: body['token'] }
    when '422'
      body = JSON.parse response.body

      { success: false,
        error_code: 'validation_error',
        fakepay_error_code: body['error_code'] }
    when '401'
      { success: false,
        error_code: 'invalid_credentials' }
    else
      { success: false,
        error_code: 'server_error' }
    end
  rescue *self.class.net_http_errors
    { success: false,
      error_code: 'network_issue' }
  end

  def subsequent_charge(data)
    payload = data.except(:amount_cents)
    payload[:amount] = data[:amount_cents]
    payload = payload.transform_values(&:to_s).to_json

    response = Net::HTTP.post @uri, payload, headers

    case response.code
    when '200'
      body = JSON.parse response.body

      { success: true,
        token: body['token'] }
    when '422'
      { success: false,
        error_code: 'invalid_token' }
    when '401'
      { success: false,
        error_code: 'invalid_credentials' }
    else
      { success: false,
        error_code: 'server_error' }
    end
  rescue *self.class.net_http_errors
    { success: false,
      error_code: 'network_issue' }
  end

  private

  def headers
    { 'Content-Type' => 'application/json', 'Authorization' => "Token token=#{@api_key}" }
  end
end
