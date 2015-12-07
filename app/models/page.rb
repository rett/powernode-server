class Page < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :account
  belongs_to :pageable, polymorphic: true
  has_many   :page_resources, dependent: :destroy

  accepts_nested_attributes_for :page_resources, allow_destroy: true

  default_scope { order('pageable_type ASC, name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true
  validates :title, presence: true
  validates_uniqueness_of :name, scope: :pageable_id

  after_initialize do
    self.id ||= UUIDTools::UUID.timestamp_create.to_s
    self.account ||= pageable.account if pageable.present?
  end

  def to_s
    name
  end
end
