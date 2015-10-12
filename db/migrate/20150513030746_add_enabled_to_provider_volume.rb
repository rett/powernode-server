class AddEnabledToProviderVolume < ActiveRecord::Migration
  def change
    add_column :provider_volumes, :enabled, :boolean, default: true, null: false
  end
end
