class NodeScript < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  VARIETIES = %w[build init mount utility]

  belongs_to :account
  has_many :pages, as: :pageable, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  attr_readonly :variety

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true, uniqueness: true
  validates_inclusion_of :variety, in: NodeScript::VARIETIES

  NodeScript::VARIETIES.each do |v|
    scope "#{v}_variety".to_sym, -> { where(variety: v) }
    define_method("#{v}_variety?") { variety == v }
  end

  def to_s
    name
  end
end
