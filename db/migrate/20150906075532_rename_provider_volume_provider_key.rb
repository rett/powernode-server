class RenameProviderVolumeProviderKey < ActiveRecord::Migration
  def change
    rename_column :provider_volumes, :provider_id, :provider_region_id
  end
end
