class Provider < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  VARIETIES = %w[aws openstack]

  belongs_to :account
  has_many :provider_regions

  attr_readonly :variety

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, presence: true, format: { with: /\A[a-z]*\z/ }, uniqueness: true
  validates_inclusion_of :variety, in: Provider::VARIETIES

  def to_s
    name
  end
end
