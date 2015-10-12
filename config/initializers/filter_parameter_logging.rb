# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Powernode.config.filter_parameters += [:active_merchant_billing_credit_card,
                                       :password,
                                       :password_confirmation,
                                       :key,
                                       :key_confirmation]
