class ChangeNodeInstanceIpAddresses < ActiveRecord::Migration
  def change
    remove_column :node_instances,  :public_ip_address,         :string
    remove_column :node_instances,  :private_ip_address,        :string
    remove_column :node_instances,  :private_ip_device,         :string,  limit: 255
    remove_column :node_instances,  :private_ip_domain,         :string,  limit: 255
    remove_column :node_instances,  :private_ip_gateway,        :string,  limit: 255
    remove_column :node_instances,  :private_ip_netmask,        :string,  limit: 255
    remove_column :node_instances,  :private_ip_primary_dns,    :string,  limit: 255
    remove_column :node_instances,  :private_ip_secondary_dns,  :string,  limit: 255
    remove_column :node_instances,  :private_ip_static,         :boolean,               default: false, null: false
    remove_column :node_instances,  :private_mac_address,       :string,  limit: 255,   default: '',    null: false
    add_column    :node_instances,  :private_ip_address,        :inet
    add_column    :node_instances,  :private_ip_device,         :string,  limit: 255,   default: '',    null: false
    add_column    :node_instances,  :private_ip_gateway,        :inet
    add_column    :node_instances,  :private_ip_netmask,        :inet
    add_column    :node_instances,  :private_ip_primary_dns,    :inet
    add_column    :node_instances,  :private_ip_secondary_dns,  :inet
    add_column    :node_instances,  :private_ip_static,         :boolean,               default: false, null: false
    add_column    :node_instances,  :private_mac_address,       :macaddr
    add_column    :node_instances,  :public_ip_address,         :inet
    add_column    :node_instances,  :vpn_ip_address,            :inet
  end
end
