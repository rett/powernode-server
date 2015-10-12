class ProviderNetworkSubnet < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :provider_availability_zone
  belongs_to :provider_network

  default_scope { order('name ASC') }

  validates :id, uniqueness: true
  validates :account, presence: true
  validates :entity, format: { with: /\A[a-zA-Z0-9_-]*\z/ }, presence: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true
  validates :network, presence: true, inclusion: { in: Proc.new { |n| n.provider_network.network } }
  validates_uniqueness_of :name, scope: :account_id

  attr_readonly :entity, :network

  def to_s
    name
  end
end
