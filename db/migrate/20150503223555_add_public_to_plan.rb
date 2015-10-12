class AddPublicToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :enabled, :boolean, default: true, null: false
    add_column :plans, :public,  :boolean, default: true, null: false
  end
end
