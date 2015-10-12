class AddAccountIdToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :account_id, :uuid
    add_index  :plans, :account_id
  end
end
