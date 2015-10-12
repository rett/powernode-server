class DropSubscriptionTables < ActiveRecord::Migration
  def change
    #
    # Drop subscription tables
    #
    drop_table    :subscriptions
    drop_table    :subscription_affiliates
    drop_table    :subscription_discounts
    drop_table    :subscription_payments
  end
end
