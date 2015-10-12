class RemoveTierLimits < ActiveRecord::Migration
  def change
    remove_column :node_architectures,     :tier,       :integer, default: 1, null: false
    remove_column :node_module_categories, :tier,       :integer, default: 1, null: false
    remove_column :node_templates,         :tier,       :integer, default: 1, null: false
    remove_column :plans,                  :tier_limit, :integer, default: 1, null: false
  end
end
