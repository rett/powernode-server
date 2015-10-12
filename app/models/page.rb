class Page < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true, uniqueness: true
  validates :title, presence: true

  def to_s
    name
  end
end
