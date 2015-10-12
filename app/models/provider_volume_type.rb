class ProviderVolumeType < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :mount_script, class_name: 'NodeScript'
  has_many   :provider_volumes

  default_scope { order('name ASC') }

  validates :id, uniqueness: true
  validates :name, presence: true, format: { with: /\A[a-z]*\z/ }, uniqueness: true

  def to_s
    name
  end
end
