class AddStripeAccessToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :stripe_access_token,    :string, default: '', null: false
    add_column :accounts, :stripe_publishable_key, :string, default: '', null: false
    add_column :accounts, :stripe_user,            :string, default: '', null: false
  end
end
