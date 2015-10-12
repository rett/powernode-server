class ChangeInvitationRecipientDefault < ActiveRecord::Migration
  def change
    change_column_default :invitations, :recipient, ''
    change_column_null    :invitations, :recipient, false
  end
end
