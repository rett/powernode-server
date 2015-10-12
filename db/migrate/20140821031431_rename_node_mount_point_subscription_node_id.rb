class RenameNodeMountPointSubscriptionNodeId < ActiveRecord::Migration
  def change
    rename_column :node_mount_point_subscriptions, :node_id, :node_instance_id
  end
end
