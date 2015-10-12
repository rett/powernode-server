class UpdateProviderTables < ActiveRecord::Migration
  def change
    #
    # Rename provider tables
    #
    rename_table  :providers,                                     :provider_connections
    rename_table  :provider_endpoints,                            :provider_regions
    rename_table  :provider_endpoint_instance_type_subscriptions, :provider_region_instance_type_subscriptions
    rename_table  :provider_endpoint_volume_type_subscriptions,   :provider_region_volume_type_subscriptions
    rename_table  :provider_endpoint_types,                       :providers

    #
    # Provider changes
    #
    add_column    :providers,                                     :variety,                     :string,  default: 'aws',   null: false
    add_column    :provider_regions,                              :availability_zones,          :text,    default: '[]',    null: false
    rename_column :provider_regions,                              :provider_endpoint_type_id,   :provider_id
    rename_column :provider_region_instance_type_subscriptions,   :provider_endpoint_id,        :provider_region_id
    rename_column :provider_region_volume_type_subscriptions,     :provider_endpoint_id,        :provider_region_id
    remove_column :provider_connections,                          :availability_zone,           :string,  default: '',      null: false
    rename_column :provider_connections,                          :provider_endpoint_id,        :provider_id
    rename_column :provider_networks,                             :provider_id,                 :provider_region_id
    rename_index  :provider_region_instance_type_subscriptions,   :index_endpoint_instance_type_sub_on_node_instance_type_id, :index_region_instance_type_sub_on_node_instance_type_id
    rename_index  :provider_region_instance_type_subscriptions,   :index_endpoint_instance_type_sub_on_provider_endpoint_id, :index_region_instance_type_sub_on_provider_region_id
    rename_index  :provider_region_volume_type_subscriptions,     :index_endpoint_volume_type_sub_on_endpoint_id, :index_region_volume_type_sub_on_provider_region_id
    rename_index  :provider_region_volume_type_subscriptions,     :index_endpoint_volume_type_sub_on_volume_type_id, :index_region_volume_type_sub_on_volume_type_id

    #
    # Node and node instance changes
    #
    remove_column :nodes,                                         :auto_scaling,                :boolean, default: false,   null: false
    remove_column :nodes,                                         :dynamic_instance_count,      :integer, default: 0
    remove_column :nodes,                                         :dynamic_instance_max,        :integer, default: 1
    remove_column :nodes,                                         :dynamic_instance_min,        :integer, default: 0
    remove_column :nodes,                                         :provider_id,                 :uuid
    remove_column :nodes,                                         :provider_instance_type_id,   :uuid
    remove_column :nodes,                                         :provider_network_subnet_id,  :uuid
    rename_column :node_instances,                                :provider_id,                 :provider_connection_id
    add_column    :node_instances,                                :provider_region_id,          :uuid
    add_column    :node_instances,                                :provider_network_subnet_id,  :uuid
  end
end
