class AddPerAttributeIvAndSalt < ActiveRecord::Migration
  def change
    # Recreate nodes encrypted ssh_key columns
    remove_column :nodes,                 :encrypted_ssh_key,          :string, default: '', null: false
    add_column    :nodes,                 :encrypted_ssh_key,          :string
    add_column    :nodes,                 :encrypted_ssh_key_iv,       :string
    add_column    :nodes,                 :encrypted_ssh_key_salt,     :string

    # Recreate node_instances encrypted ssh_key columns
    remove_column :node_instances,        :encrypted_key,              :string, default: '', null: false
    add_column    :node_instances,        :encrypted_key,              :string
    add_column    :node_instances,        :encrypted_key_iv,           :string
    add_column    :node_instances,        :encrypted_key_salt,         :string

    # Recreate provider_connections encrypted secret_key columns
    remove_column :provider_connections,  :encrypted_secret_key,       :string, default: '', null: false
    add_column    :provider_connections,  :encrypted_secret_key,       :string
    add_column    :provider_connections,  :encrypted_secret_key_iv,    :string
    add_column    :provider_connections,  :encrypted_secret_key_salt,  :string
  end
end
