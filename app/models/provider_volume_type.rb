class ProviderVolumeType < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :mount_script, class_name: 'NodeScript'
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :provider_volumes

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  validates :id, uniqueness: true
  validates :name, presence: true, format: { with: /\A[a-z]*\z/ }, uniqueness: true

  def to_s
    name
  end
end
