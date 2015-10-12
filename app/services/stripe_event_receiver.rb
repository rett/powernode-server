class StripeEventReceiver
  attr_reader :account
  attr_reader :event

  def call(e)
    @event = e
    @account = Account.find_by(id: @event.data.object.id)
    stripe_method = "stripe_#{@event.type.tr('.', '_')}".gsub(/\W/, '').downcase
    self.send(stripe_method) if self.respond_to?(stripe_method)
  end

  private

  def stripe_customer_updated
    if event.data.object.delinquent
      account.delinquent
      account.save if account.changed?
    else
      account.active
      account.save if account.changed?
    end
  end
end
