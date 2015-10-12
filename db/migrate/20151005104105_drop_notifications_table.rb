class DropNotificationsTable < ActiveRecord::Migration
  def change
    add_column :operations, :progress, :integer, default: 0, null: false
    drop_table :notifications
  end
end
