class ChangeActiveMerchantToStripe < ActiveRecord::Migration
  def change
    #
    # Account changes
    #
    add_column    :accounts,            :plan_id,                   :uuid
    add_column    :accounts,            :state,                     :string
    add_column    :accounts,            :stripe_card,               :string
    add_column    :accounts,            :stripe_card_exp_month,     :string
    add_column    :accounts,            :stripe_card_exp_year,      :string
    add_column    :accounts,            :stripe_card_last4,         :string
    add_column    :accounts,            :stripe_subscription,       :string
    add_column    :accounts,            :stripe_token,              :string
    add_column    :accounts,            :stripe_trial_end,          :string
    add_column    :accounts,            :stripe_trial_start,        :string

    #
    # Plan changes
    #
    rename_table  :subscription_plans,  :plans
    add_column    :plans,               :currency,                  :string,          default: 'usd', null: false
    add_column    :plans,               :statement_descriptor,      :string,          limit: 22
    add_column    :plans,               :trial_period_days,         :integer
    remove_column :plans,               :renewal_period,            :integer,         default: 1
    remove_column :plans,               :setup_amount,              :decimal,         precision: 10,  scale: 2,   default: 0.0
    remove_column :plans,               :unit_price,                :float
    rename_column :plans,               :trial_interval,            :interval
    rename_column :plans,               :trial_period,              :interval_count
  end
end
