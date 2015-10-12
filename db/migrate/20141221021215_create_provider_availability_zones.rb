class CreateProviderAvailabilityZones < ActiveRecord::Migration
  def change
    create_table :provider_availability_zones, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :provider_region_id,                                                null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.string      :entity,                                            default: '',    null: false
      t.boolean     :enabled,                                           default: false, null: false
      t.boolean     :public,                                            default: false, null: false
    end

    add_column    :node_instances, :provider_availability_zone_id, :uuid
    add_column    :provider_network_subnets, :provider_availability_zone_id, :uuid
    remove_column :provider_regions, :availability_zones, :text, default: '[]',         null: false
  end
end
