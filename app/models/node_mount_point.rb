class NodeMountPoint < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :account
  belongs_to :mount_script, class_name: 'NodeScript'
  belongs_to :node_module
  belongs_to :node_mount_point_dependency, class_name: 'NodeMountPoint'
  has_many :node_mount_point_subscriptions
  has_many :node_instances, through: :node_mount_point_subscriptions
  has_many :pages, as: :pageable, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  serialize :options, JSON

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }, presence: true, uniqueness: true
  validates :device, presence: true
  validates :path, presence: true

  validate  :prevent_dependency_loop, on: [:create, :update]

  def parameters
    options.try(:[], 'parameters')
  end

  def parameters=(arg)
    options['parameters'] = arg
  end

  def to_s
    name
  end

  def <=>(other)
    [0] <=> [id == other.node_mount_point_dependency_id ? 1 : -1]
  end

  private

  def prevent_dependency_loop
    if (dependency = NodeMountPoint.find_by(id: node_mount_point_dependency_id))
      errors.add(:base, "#{dependency.name} already depends on this mount point.") if id == dependency.node_mount_point_dependency_id
    end
  end
end
