class StripeCustomer
  attr_reader :account
  attr_reader :stripe_customer

  def initialize(a)
    @account = a
    if account.new_record?
      @stripe_customer = create_stripe_customer
    else
      begin
        @stripe_customer = Stripe::Customer.retrieve(account.id)
      rescue Stripe::InvalidRequestError
        @stripe_customer = create_stripe_customer
      end
    end
  end

  def subscription
    @subscription ||= stripe_customer.subscriptions.first || stripe_customer.subscriptions.create(plan: account.plan_id)
  rescue Stripe::StripeError => e
    account.errors[:base] << e.message
    nil
  end

  def destroy!
    stripe_customer.delete
    true
  rescue Stripe::StripeError => e
    account.errors[:base] << e.message
    false
  end

  def update!
    if account.stripe_token.present?
      stripe_customer.source = account.stripe_token
      account.stripe_token = nil
    end
    stripe_customer.description = account.name
    stripe_customer.email = account.email
    stripe_customer.save
    if account.plan_id != subscription.plan.id
      subscription.plan = account.plan.id
      subscription.save
    end
    account.stripe_subscription = subscription.id
    account.stripe_trial_start = subscription.trial_start
    account.stripe_trial_end = subscription.trial_end
    true
  rescue Stripe::StripeError => e
    account.errors[:base] << e.message
    false
  end

  private

  def create_stripe_customer
    Stripe::Customer.create(id: account.id,
                            description: account.name,
                            email: account.email,
                            plan: account.plan.id)
  end
end
