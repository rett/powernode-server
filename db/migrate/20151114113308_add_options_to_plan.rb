class AddOptionsToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :options, :text, default: '{}', null: false
  end
end
