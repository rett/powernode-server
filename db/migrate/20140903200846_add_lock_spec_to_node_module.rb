class AddLockSpecToNodeModule < ActiveRecord::Migration
  def change
    add_column :node_modules, :lock_spec, :boolean, default: false, null: false
  end
end
