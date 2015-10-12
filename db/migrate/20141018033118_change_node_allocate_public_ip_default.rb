class ChangeNodeAllocatePublicIpDefault < ActiveRecord::Migration
  def up
    change_column :nodes,                                         :allocate_public_ip,          :boolean, default: true
  end

  def down
    change_column :nodes,                                         :allocate_public_ip,          :boolean, default: false
  end
end
