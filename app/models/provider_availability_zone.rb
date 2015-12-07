class ProviderAvailabilityZone < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :account
  belongs_to :provider_region
  has_many :node_instances
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :provider_network_subnets

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  validates :account, presence: true
  validates :entity, presence: true
  validates :provider_region, presence: true
  validates :id, uniqueness: true
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }
  validates_uniqueness_of :name, scope: :account_id

  attr_readonly :entity

  def to_s
    name
  end
end
