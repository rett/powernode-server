class ChangeUserRolesMaskToRolesArray < ActiveRecord::Migration
  def change
    remove_column :users, :roles_mask,  :integer, default: 0,     null: false
    add_column    :users, :roles,       :text,    default: '[]',  null: false
  end
end
