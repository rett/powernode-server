class AccountDelegation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :account
  belongs_to :user

  scope :enabled, -> { where('expiration IS NULL OR expiration > ?', DateTime.now) }

  validates :id, uniqueness: true
end
