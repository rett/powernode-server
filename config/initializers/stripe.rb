STRIPE_PUBLIC_KEY = Powernode.config.stripe_public_key
Stripe.api_key = Powernode.config.stripe_api_key

#
# Configure Stripe Event
#
StripeEvent.authentication_secret = Powernode.config.stripe_webhook_secret
StripeEvent.configure do |events|
  events.all StripeEventReceiver.new
end
