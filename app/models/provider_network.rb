class ProviderNetwork < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :provider_region
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :provider_network_subnets, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  validates :id, uniqueness: true
  validates :account, presence: true
  validates :entity, format: { with: /\A[a-zA-Z0-9_-]*\z/ }, presence: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true
  validates :network, presence: true
  validates_associated :provider_network_subnets
  validates_uniqueness_of :name, scope: :account_id

  attr_readonly :entity, :network

  before_create do
    self.status ||= 'pending'
  end

  def to_s
    name
  end
end
