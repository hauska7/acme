module CreateSignupService
  def self.call(params)
    errors = CreateSignupValidator.call(params)
    return { status: 'validation_failed', errors: errors } if errors.present?

    plan_price_cents = PlanPriceService.call(params['plan'])

    fakepay_data = {
      amount_cents: plan_price_cents,
      card_number: params['billing']['card_number'],
      cvv: params['billing']['cvv'],
      expiration_month: params['billing']['expiration_month'],
      expiration_year: params['billing']['expiration_year'],
      zip_code: params['billing']['zip_code']
    }
    fakepay_result = FakepayClient.build.first_charge(fakepay_data)

  end
end
