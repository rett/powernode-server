class ChangeInvitationScheme < ActiveRecord::Migration
  def change
    #
    # Invitation changes
    #
    rename_column :invitations,         :subscription_id,           :user_id
  end
end
