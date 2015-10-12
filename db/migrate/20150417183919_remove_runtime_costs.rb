class RemoveRuntimeCosts < ActiveRecord::Migration
  def change
    remove_column :provider_instance_types, :runtime_cost, :decimal, default: 0.0, null: false
    remove_column :node_templates,          :runtime_cost, :decimal, default: 0.0
  end
end
