class AddPageableIdToPage < ActiveRecord::Migration
  def change
    add_column :pages, :pageable_id, :uuid
    add_column :pages, :pageable_type, :string
    add_index  :pages, :pageable_id
  end
end
