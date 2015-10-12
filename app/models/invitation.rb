class Invitation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :user

  scope :available, -> { where(recipient: '') }

  validates :account, presence: true
  validates :id, uniqueness: true

  after_save :email_recipient

  def to_s
    id
  end

  private

  def email_recipient
    InvitationNotifier.delay.invitation(self) if self[:recipient].present?
  end
end
