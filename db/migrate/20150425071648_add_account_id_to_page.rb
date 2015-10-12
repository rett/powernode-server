class AddAccountIdToPage < ActiveRecord::Migration
  def change
    add_column :pages, :account_id, :uuid
    add_index  :pages, :account_id
  end
end
