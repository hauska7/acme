module PlanPriceService
  def self.call(plan)
    case plan
    when 'bronze_box'
      1999
    when 'silver_box'
      4900
    when 'gold_box'
      9900
    end
  end
end
