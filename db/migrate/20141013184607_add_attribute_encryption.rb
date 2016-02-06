class AddAttributeEncryption < ActiveRecord::Migration
  def change
    add_column    :accounts,                                      :encryption_key,              :text
    remove_column :node_instances,                                :agent_key,                   :text
    rename_column :nodes,                                         :ssh_key,                     :encrypted_ssh_key
    rename_column :provider_connections,                          :secret_key,                  :encrypted_secret_key
  end
end
