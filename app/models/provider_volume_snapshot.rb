class ProviderVolumeSnapshot < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :provider_volume

  attr_readonly :entity

  default_scope { order('name ASC') }

  validates :id, uniqueness: true
  validates :entity, format: { with: /\A[a-zA-Z0-9_-]*\z/ }, presence: true, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9_-]*\z/ }, presence: true, uniqueness: true

  before_create do
    self.status ||= 'pending'
  end

  before_save do
    self.status.downcase! if status_changed?
  end

  def to_s
    name
  end
end
