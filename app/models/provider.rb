class Provider < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  VARIETIES = %w[aws openstack]

  belongs_to :account
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :provider_regions

  accepts_nested_attributes_for :pages, allow_destroy: true

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
