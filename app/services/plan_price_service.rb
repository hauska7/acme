# frozen_string_literal: true

# Map plan to price
module PlanPriceService
  MAPPING = {
    bronze_box: 1999,
    silver_box: 4900,
    gold_box: 9900
  }.freeze

  def self.call(plan)
    MAPPING[plan&.to_sym]
  end
end
