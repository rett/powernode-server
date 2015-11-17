class RemoveStripeTokenFromAccount < ActiveRecord::Migration
  def change
    remove_column :accounts, :stripe_token, :string
  end
end
