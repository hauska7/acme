# frozen_string_literal: true

# Subscription validator
module CreateSubscriptionValidator
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.call(params)
    # only validating presence as per assignment assumptions

    result = []
    if params[:name].blank?
      error = {}
      error[:message] = 'Invalid name'
      error[:fields] = ['name']
      result << error
    end
    if params[:plan].blank?
      error = {}
      error[:message] = 'Invalid plan'
      error[:fields] = ['plan']
      result << error
    end
    if params.dig(:shipping_address, :street).blank?
      error = {}
      error[:message] = 'Invalid shipping address street'
      error[:fields] = ['shipping_address/street']
      result << error
    end
    if params.dig(:shipping_address, :city).blank?
      error = {}
      error[:message] = 'Invalid shipping address city'
      error[:fields] = ['shipping_address/city']
      result << error
    end
    if params.dig(:shipping_address, :zip_code).blank?
      error = {}
      error[:message] = 'Invalid shipping address zip code'
      error[:fields] = ['shipping_address/zip_code']
      result << error
    end
    if params.dig(:shipping_address, :country).blank?
      error = {}
      error[:message] = 'Invalid shipping address country'
      error[:fields] = ['shipping_address/country']
      result << error
    end
    if params.dig(:billing, :card_number).blank?
      error = {}
      error[:message] = 'Invalid card number'
      error[:fields] = ['billing/card_number']
      result << error
    end
    if params.dig(:billing, :cvv).blank?
      error = {}
      error[:message] = 'Invalid card number'
      error[:fields] = ['billing/cvv']
      result << error
    end
    if params.dig(:billing, :expiration_month).blank?
      error = {}
      error[:message] = 'Invalid expiration month'
      error[:fields] = ['billing/expiration_month']
      result << error
    end
    if params.dig(:billing, :expiration_year).blank?
      error = {}
      error[:message] = 'Invalid expiration year'
      error[:fields] = ['billing/expiration_year']
      result << error
    end
    if params.dig(:billing, :zip_code).blank?
      error = {}
      error[:message] = 'Invalid billing zip code'
      error[:fields] = ['billing/zip_code']
      result << error
    end

    result
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
