class AddSSHAuthorizedKeys < ActiveRecord::Migration
  def change
    add_column    :agents, :encrypted_key_iv,             :string
    add_column    :agents, :encrypted_key_salt,           :string
    add_column    :agents, :roles,                        :string,              default: '[]',  null: false
    remove_column :agents, :roles_mask,                   :integer,             default: 0,     null: false

    add_column    :nodes,  :encrypted_ssh_host_key,       :text
    add_column    :nodes,  :encrypted_ssh_host_key_iv,    :string
    add_column    :nodes,  :encrypted_ssh_host_key_salt,  :string
    add_column    :nodes,  :ssh_host_key_fingerprint,     :string
    add_column    :users,  :authorized_keys,              :text,                default: '[]',  null: false

    reversible do |change|
      change.up do
        change_column :node_instances,  :encrypted_key,   :text,    limit: nil, default: '',    null: false
      end

      change.down do
        change_column :node_instances,  :encrypted_key,   :string,  limit: 255, default: nil,   null: true
      end
    end
  end
end
