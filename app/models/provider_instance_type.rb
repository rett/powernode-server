class ProviderInstanceType < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  has_many :pages, as: :pageable, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true, uniqueness: true

  def to_s
    name
  end
end
