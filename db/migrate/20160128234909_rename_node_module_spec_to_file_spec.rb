class RenameNodeModuleSpecToFileSpec < ActiveRecord::Migration
  def change
    rename_column :node_modules, :spec, :file_spec
  end
end
