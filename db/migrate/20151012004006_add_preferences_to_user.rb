class AddPreferencesToUser < ActiveRecord::Migration
  def change
    add_column :users, :preferences, :text, default: '{}', null: false
  end
end
