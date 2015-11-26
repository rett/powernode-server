class ProviderRegion < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :provider
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :provider_availability_zones
  has_many :provider_region_instance_type_subscriptions, dependent: :destroy
  has_many :provider_instance_types, through: :provider_region_instance_type_subscriptions
  has_many :provider_networks
  has_many :provider_network_subnets, through: :provider_networks
  has_many :provider_region_volume_type_subscriptions, dependent: :destroy
  has_many :provider_volume_types, through: :provider_region_volume_type_subscriptions

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  serialize :capabilities, JSON

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }, uniqueness: true
  validates :endpoint_url, presence: true, format: URI::regexp(%w[http https])
  validates :kernel_image, :machine_image, :ramdisk_image, format: { with: /\A[a-zA-Z0-9\/._-]*\z/ }
  validates :provider, presence: true

  def to_s
    name
  end
end
