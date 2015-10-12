class CreditCard
  ATTRIBUTES = [:cvc, :exp_month, :exp_year, :name, :number]

  attr_accessor *ATTRIBUTES

  def initialize(params = {})
    ATTRIBUTES.each do |attribute|
      self.send("#{attribute}=", params[attribute])
    end
  end
end
