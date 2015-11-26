class ProviderConnection < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::EncryptionExtensions
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :provider
  has_many :node_instances
  has_many :nodes
  has_many :operations, as: :operable
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :provider_regions, through: :provider
  has_many :provider_instance_types, through: :provider_regions
  has_many :provider_networks, through: :provider_regions
  has_many :provider_network_subnets, through: :provider_networks

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  attr_encrypted :secret_key, key: :encryption_key, mode: :per_attribute_iv_and_salt

  scope :enabled, -> { where(enabled: true) }

  delegate :variety, to: :provider

  validates :access_key, presence: true
  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }
  validates :provider, presence: true
  validates_uniqueness_of :name, scope: :account_id

  def to_s
    name
  end
end
