class AddAccountIdToProviderVolumeMembers < ActiveRecord::Migration
  def change
    add_column :provider_volume_members, :account_id, :uuid
    add_index  :provider_volume_members, :account_id
  end
end
