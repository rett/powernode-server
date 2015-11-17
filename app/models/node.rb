class Node < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::EncryptionExtensions
  include Powernode::UUIDExtensions

  belongs_to :account
  belongs_to :agent
  belongs_to :primary_instance, class_name: 'NodeInstance'
  belongs_to :node_template
  belongs_to :sync_script, class_name: 'NodeScript', foreign_key: :sync_script_id
  has_many :node_instances, dependent: :destroy, validate: true
  has_many :node_module_subscriptions, dependent: :destroy
  has_many :node_modules, through: :node_module_subscriptions, source: :node_module
  has_many :operations, as: :operable
  has_many :provider_volumes, through: :node_instances
  has_many :puppet_modules, through: :node_modules
  has_many :puppet_resources, through: :puppet_modules

  attr_accessor :node_instance
  attr_encrypted :ssh_key, key: :encryption_key, mode: :per_attribute_iv_and_salt

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  delegate :instance_limit,    to: :account
  delegate :proxy_url,         to: :agent
  delegate :admin_user,        to: :node_template
  delegate :node_architecture, to: :node_template
  delegate :node_platform,     to: :node_template, allow_nil: true
  delegate :build_script,      to: :node_platform
  delegate :init_script,       to: :node_platform

  validates :account, presence: true
  validates :agent, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9_-]*\z/ }, presence: true
  validates :primary_instance, inclusion: { in: Proc.new { |n| n.node_instances } }, allow_nil: true
  validates :node_template, presence: true
  validates_uniqueness_of :name, scope: :account_id
  validate  :enforce_limits, on: :create

  before_destroy { |n| n.node_instances.cloud_variety.size == 0 && n.node_instances.dynamic_variety.size == 0 }
  before_save :destroy_invalid_associations, if: :node_template_id_changed?

  def copy_path(node_module)
    node_module_subscriptions.find_by(node_module_id: node_module).try(:node_module_copy_path).try(:path)
  end

  def dynamic_instance_max_available
    account.instance_limit - (node_instances.cloud_variety.size + node_instances.physical_variety.size)
  end

  def enabled
    new_record? || account.enabled? ? self[:enabled] : false
  end
  alias enabled? enabled

  def init_script_id
    init_script.try(:id)
  end

  def module_extension
    Powernode.config.module_extension
  end

  def module_info_extension
    Powernode.config.module_info_extension
  end

  def module_update_extension
    Powernode.config.module_update_extension
  end

  alias_method :orig_sync_script, :sync_script
  def sync_script
    custom_sync_script? && orig_sync_script.present? ? orig_sync_script : node_platform.try(:sync_script)
  end

  def sync_script_id
    sync_script.try(:id)
  end

  def total_instances
    node_instances.size
  end

  def update_cloud_instances
    if (node_operation = node_operations.find_by(command: 'update_cloud_instances'))
      node_operation.scheduled_at
    else
      nil
    end
  end

  def to_s
    name
  end

  def node_module_subscription(node_module)
    node_module_subscriptions.find_by(node_module_id: node_module)
  end

  private

  def destroy_invalid_associations
    node_modules.each do |m|
      node_module_subscription(m).destroy if node_module_subscription(m) && m.node_platform != node_platform
    end
  end

  def enforce_limits
    errors.add(:base, I18n.t('flash.nodes.create.danger_limit_reached')) unless account.present? && account.nodes.size < account.node_limit
  end
end
