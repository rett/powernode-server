class StripePlan
  attr_reader :plan
  attr_reader :stripe_plan

  def initialize(p)
    @plan = p
    if plan.new_record?
      @stripe_plan = create_plan
    else
      begin
        @stripe_plan = Stripe::Plan.retrieve(plan.id)
      rescue Stripe::InvalidRequestError
        @stripe_plan = create_plan
      end
    end
  end

  def destroy!
    stripe_plan.delete
    true
  rescue Stripe::StripeError => e
    plan.errors[:base] << e.message
    false
  end

  def update!
    stripe_plan.name = plan.name
    stripe_plan.metadata = { description: plan.description }
    stripe_plan.statement_descriptor = plan.statement_descriptor
    stripe_plan.save
    true
  rescue Stripe::StripeError => e
    plan.errors[:base] << e.message
    false
  end

  private

  def create_plan
    Stripe::Plan.create(id: plan.id,
                        amount: (plan.amount.to_f * 100).to_i,
                        currency: plan.currency,
                        interval: plan.interval,
                        interval_count: plan.interval_count,
                        metadata: { description: plan.description },
                        name: plan.name,
                        statement_descriptor: plan.statement_descriptor,
                        trial_period_days: plan.trial_period_days)
  end
end
