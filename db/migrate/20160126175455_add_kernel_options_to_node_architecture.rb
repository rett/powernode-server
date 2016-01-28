class AddKernelOptionsToNodeArchitecture < ActiveRecord::Migration
  def change
    add_column :node_architectures, :kernel_options, :string, limit: 255, default: '', null: false
  end
end
