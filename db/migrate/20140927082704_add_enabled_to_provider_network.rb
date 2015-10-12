class AddEnabledToProviderNetwork < ActiveRecord::Migration
  def change
    add_column :provider_networks,        :enabled, :boolean, default: true, null: false
    add_column :provider_network_subnets, :enabled, :boolean, default: true, null: false
  end
end
