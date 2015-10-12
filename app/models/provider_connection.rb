class ProviderConnection < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::EncryptionExtensions
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :provider
  has_many :provider_regions, through: :provider
  has_many :provider_instance_types, through: :provider_regions
  has_many :provider_networks, through: :provider_regions
  has_many :provider_network_subnets, through: :provider_networks
  has_many :node_instances
  has_many :nodes
  has_many :operations, as: :operable

  default_scope { order('name ASC') }

  attr_encryptor :secret_key, key: :encryption_key

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
