class AddEventsToOperation < ActiveRecord::Migration
  def change
    add_column :operations, :events, :text, default: '[]', null: false
    add_column :operations, :icon, :string, default: '',   null: false
  end
end
