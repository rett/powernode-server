class AddAccountIdToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :account_id, :uuid
    add_index  :providers, :account_id
  end
end
