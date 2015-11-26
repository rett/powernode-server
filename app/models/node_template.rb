class NodeTemplate < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :node_platform
  has_many :node_template_module_subscriptions, dependent: :destroy
  has_many :node_modules, through: :node_template_module_subscriptions
  has_many :node_module_categories, through: :node_modules
  has_many :nodes, dependent: :destroy
  has_many :pages, as: :pageable, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  delegate :node_architecture, to: :node_platform, allow_nil: true

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }, presence: true
  validates_uniqueness_of :name, scope: :node_platform_id
  validates :node_platform, presence: true

  before_save :remove_invalid_module_subscriptions
  before_destroy :prevent_destroy_if_nodes

  def to_s
    name
  end

  private

  def prevent_destroy_if_nodes
    if nodes.size > 0
      self.errors[:base] << 'Cannot delete template while nodes exist.'
      false
    end
  end

  def remove_invalid_module_subscriptions
    self.node_modules -= node_modules.where.not(node_platform_id: node_platform.id)
    self.node_modules -= node_modules.where(public: false).where.not(account_id: account_id)
  end
end
