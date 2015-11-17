Powernode.config.stripe.publishable_key = Powernode.config.stripe_publishable_key
Stripe.api_key = Powernode.config.stripe_secret_key

#
# Configure Stripe Event
#
StripeEvent.authentication_secret = Powernode.config.stripe_webhook_secret
StripeEvent.configure do |events|
  events.all StripeEventReceiver.new
end
