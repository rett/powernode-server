class NodePlatform < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :account
  belongs_to :build_script, class_name: 'NodeScript'
  belongs_to :init_script, class_name: 'NodeScript'
  belongs_to :sync_script, class_name: 'NodeScript'
  belongs_to :node_architecture
  has_many :node_modules, dependent: :destroy
  has_many :node_templates, dependent: :destroy
  has_many :nodes, through: :node_templates
  has_many :pages, as: :pageable, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }, presence: true, uniqueness: true
  validates :node_architecture, presence: true

  before_destroy :prevent_destroy_if_templates

  def to_s
    name
  end

  private

  def prevent_destroy_if_templates
    if node_templates.size > 0
      self.errors[:base] << 'Cannot delete platform while templates exist.'
      false
    end
  end
end
