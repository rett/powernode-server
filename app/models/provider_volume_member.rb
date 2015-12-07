class ProviderVolumeMember < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

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

  def name
    if provider_volume.provider_volume_members.size > 1
      "#{provider_volume.name}-volume-#{provider_volume.provider_volume_members.index(self)}"
    else
      "#{provider_volume.name}-volume"
    end
  end

  def to_s
    name
  end
end
