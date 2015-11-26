class RemoveDetailsColumns < ActiveRecord::Migration
  def change
    remove_column :account_delegations,         :details, :text,      default: '',    null: false
    remove_column :agents,                      :details, :text,      default: '',    null: false
    remove_column :node_architectures,          :details, :text,      default: '',    null: false
    remove_column :node_instances,              :details, :text,      default: '',    null: false
    remove_column :node_module_categories,      :details, :text,      default: '',    null: false
    remove_column :node_module_copy_paths,      :details, :text,      default: '',    null: false
    remove_column :node_modules,                :details, :text,      default: '',    null: false
    remove_column :node_mount_points,           :details, :text,      default: '',    null: false
    remove_column :node_platforms,              :details, :text,      default: '',    null: false
    remove_column :node_scripts,                :details, :text,      default: '',    null: false
    remove_column :node_templates,              :details, :text,      default: '',    null: false
    remove_column :nodes,                       :details, :text,      default: '',    null: false
    remove_column :plans,                       :details, :text,      default: '',    null: false
    remove_column :provider_availability_zones, :details, :text,      default: '',    null: false
    remove_column :provider_connections,        :details, :text,      default: '',    null: false
    remove_column :provider_instance_types,     :details, :text,      default: '',    null: false
    remove_column :provider_network_subnets,    :details, :text,      default: '',    null: false
    remove_column :provider_networks,           :details, :text,      default: '',    null: false
    remove_column :provider_regions,            :details, :text,      default: '',    null: false
    remove_column :provider_volume_types,       :details, :text,      default: '',    null: false
    remove_column :provider_volumes,            :details, :text,      default: '',    null: false
    remove_column :providers,                   :details, :text,      default: '',    null: false
    remove_column :puppet_resources,            :details, :text,      default: '',    null: false
  end
end
