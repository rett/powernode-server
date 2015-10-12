class AddAccountIdToProviderNetworkSubnet < ActiveRecord::Migration
  def change
    add_column :provider_network_subnets, :account_id, :uuid, null: false
  end
end
