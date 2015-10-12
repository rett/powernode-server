class AddNodeModuleIdToNodeMountPoint < ActiveRecord::Migration
  def change
    add_column :node_mount_points, :node_module_id, :uuid
  end
end
