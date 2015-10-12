class NodeModuleCategory < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  has_many :node_modules, dependent: :destroy

  attr_readonly :variety

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }, presence: true, uniqueness: true
  validates_inclusion_of :variety, in: NodeModule::VARIETIES

  validates_numericality_of :priority,
                            only_integer: true,
                            greater_than_or_equal_to: Powernode.config.module_priority_range[0],
                            less_than_or_equal_to: Powernode.config.module_priority_range[1]

  NodeModule::VARIETIES.each do |v|
    belongs_to "#{v}_category".to_sym, class_name: 'NodeModuleCategory', foreign_key: "#{v}_category_id"
    scope "#{v}_variety".to_sym, -> { where(variety: v) }
    define_method("#{v}_variety?".to_sym) { variety == v }
  end

  def to_s
    name
  end
end
