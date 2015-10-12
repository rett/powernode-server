class CreateProviderNetworking < ActiveRecord::Migration
  def change
    #
    # Create Provider Networks
    #
    create_table :provider_networks, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :provider_id,                                                       null: false
      t.inet        :network,                                                           null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.string      :entity,                                            default: '',    null: false
      t.string      :dns1,                                              default: '',    null: false
      t.string      :dns2,                                              default: '',    null: false
      t.string      :ntp_server,                                        default: '',    null: false
      t.string      :tenancy,                                           default: '',    null: false
      t.string      :status,                                                            null: false
    end

    add_index :provider_networks, :account_id
    add_index :provider_networks, :provider_id

    #
    # Create Provider Network Subnets
    #
    create_table :provider_network_subnets, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :provider_network_id,                                               null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.string      :entity,                                            default: '',    null: false
      t.inet        :network,                                                           null: false
    end

    add_index :provider_network_subnets, :provider_network_id

    #
    # Node and Node Instance changes
    #
    add_column    :nodes, :provider_network_subnet_id,            :uuid
    add_column    :nodes, :allocate_public_ip,                    :boolean,                             default: false,   null: false
    remove_column :nodes,                                         :node_balancer_id,          :uuid
    rename_column :nodes,                                         :node_instance_type_id,     :provider_instance_type_id
    rename_column :node_instances,                                :node_instance_type_id,     :provider_instance_type_id
    rename_table  :node_instance_types,                           :provider_instance_types
    remove_column :provider_instance_types,                       :tier,                      :integer, default: 1,       null: false

    #
    # Operation polymorphism
    #
    add_column    :operations,                                    :operable_id,               :uuid,                      null: false
    add_column    :operations,                                    :operable_type,             :string,                    null: false
    remove_column :operations,                                    :node_id,                   :uuid
    remove_column :operations,                                    :node_instance_id,          :uuid
    remove_column :operations,                                    :node_module_id,            :uuid
    remove_column :operations,                                    :volume_id,                 :uuid

    #
    # Provider changes
    #
    add_column    :providers,                                     :availability_zone,         :string,  default: '',      null: false
    remove_column :providers,                                     :public,                    :boolean, default: false,   null: false
    remove_column :providers,                                     :tier,                      :integer, default: 1,       null: false

    #
    # Provider Endpoint changes
    #
    add_column    :provider_endpoints,                            :capabilities,              :string,  default: '[]',    null: false
    remove_column :provider_endpoints,                            :availability_zone,         :string,  default: '',      null: false
    rename_column :provider_endpoint_instance_type_subscriptions, :node_instance_type_id,     :provider_instance_type_id
    rename_column :provider_endpoint_volume_type_subscriptions,   :volume_type_id,            :provider_volume_type_id

    #
    # Rename Volume to Provider Volume
    #
    rename_table  :volumes,                                       :provider_volumes
    rename_table  :volume_members,                                :provider_volume_members
    rename_table  :volume_snapshots,                              :provider_volume_snapshots
    rename_table  :volume_types,                                  :provider_volume_types
    rename_column :provider_volumes,                              :volume_type_id,            :provider_volume_type_id
    rename_column :provider_volume_members,                       :volume_id,                 :provider_volume_id
    rename_column :provider_volume_snapshots,                     :volume_id,                 :provider_volume_id
  end
end
