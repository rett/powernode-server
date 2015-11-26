class CreatePageResources < ActiveRecord::Migration
  def change
    create_table :page_resources, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :page_id,                                                           null: false
      t.string      :name,                                                              null: false
      t.attachment  :data
      t.string      :data_checksum,                                     default: '',    null: false
    end

    add_index :page_resources, :page_id
  end
end
