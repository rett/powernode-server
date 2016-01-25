class NodeInstance < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  CLOUD_VARIETIES = %w[cloud dynamic]
  PHYSICAL_VARIETIES = %w[physical]
  VARIETIES = CLOUD_VARIETIES + PHYSICAL_VARIETIES

  belongs_to :node
  belongs_to :provider_availability_zone
  belongs_to :provider_instance_type
  belongs_to :provider_connection
  belongs_to :provider_region
  has_many :node_modules, dependent: :destroy
  has_many :node_mount_point_subscriptions, dependent: :destroy
  has_many :node_mount_points, through: :node_mount_point_subscriptions
  has_many :operations, as: :operable
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :provider_volumes
  has_many :active_volumes, class_name: 'ProviderVolume', foreign_key: 'active_instance_id'

  accepts_nested_attributes_for :pages, allow_destroy: true

  attr_encrypted :key, key: :encryption_key, mode: :per_attribute_iv_and_salt
  attr_readonly :entity, :variety

  delegate :account, to: :node
  delegate :node_template, to: :node

  default_scope { order('node_instances.name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9_-]*\z/ }, presence: true, uniqueness: true
  validates :private_ip_address, :public_ip_address, ip: { forbidden: :netmask }
  validates :private_mac_address, uniqueness: true, format: { with: /\A([0-9A-Fa-f]{2}[-:.]?){5}[0-9A-Fa-f]{2}\z/ }, allow_blank: true
  validates_inclusion_of :image_format, in: Powernode.config.image_formats, allow_blank: true
  validates_inclusion_of :variety, in: NodeInstance::VARIETIES
  validate  :enforce_limits, on: :create

  after_initialize do
    self.reset_key if key.blank?
    if variety == 'physical'
      self.status ||= 'ready'
    else
      self.status ||= 'pending'
    end
  end

  before_save do
    if private_ip_static_changed? && !private_ip_static?
      self.private_ip_address = nil
      self.private_ip_netmask = nil
      self.private_ip_gateway = nil
    end
    self.private_netboot_updated_at = Time.now if private_mac_address_changed?
    self.status.downcase! if status_changed?
  end
  after_save do
    self.node.update_attribute(:primary_instance, self) unless self.node.primary_instance.try(:valid?)
  end

  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  #reverse_geocoded_by :latitude, :longitude
  #after_validation :reverse_geocode

  has_attached_file :image,
                    default_url: '',
                    url: '',
                    path: "#{Powernode.config.image_dir}/:uuid_partition/:image_file_name"

  validates_attachment_content_type :image, content_type: /.*/

  after_image_post_process :generate_image_checksum

  NodeInstance::VARIETIES.each do |v|
    scope "#{v}_variety".to_sym, -> { where(variety: v) }
    define_method("#{v}_variety?") { variety == v }
  end

  def authenticate(supplied_key)
    enabled? && key == supplied_key
  end

  def config
    <<-EOF.strip_heredoc
      ADMIN_USER=#{node.admin_user}
      HOSTNAME=#{name}
      INIT_SCRIPT=#{node.init_script_id}
      SYNC_SCRIPT=#{node.sync_script_id}
      TMPFS_STORE=#{node.tmpfs_store}
      CHKSUM=#{Powernode.config.checksum_util}
      MAXLOOP=#{Powernode.config.loop_devices}
      PUPPET_CACHE_DIR=#{Powernode.config.puppet_cache_dir}
      SYSTEM_DIR=${UNION}#{Powernode.config.system_dir}
      SCRIPTS=${SYSTEM_DIR}/#{Powernode.config.script_dir}
      MEMORY=${SYSTEM_DIR}/#{Powernode.config.memory_dir}
      BRANCHES=${MEMORY}/#{Powernode.config.branch_dir}
      CHANGES=${MEMORY}/#{Powernode.config.changes_dir}
      RAM=${MEMORY}/#{Powernode.config.ram_dir}
      STORE=${MEMORY}/#{Powernode.config.store_dir}
      VOLUMES=${MEMORY}/#{Powernode.config.volume_dir}
      MODULE_EXT=#{Powernode.config.module_extension}
      MODULE_INFO_EXT=#{Powernode.config.module_info_extension}
      MODULE_UPDATE_EXT=#{Powernode.config.module_update_extension}
    EOF
  end

  def download_file_name
    "#{name}.#{image_format}"
  end

  def encryption_key
    account.present? ? account.encryption_key + Powernode.config.key_pepper : nil
  end

  def enforce_limits
    errors.add(:base, I18n.t('flash.node_instances.create.danger_limit_reached')) unless account.present? && account.node_instances.size < account.instance_limit
  end

  def image_file_name=(name)
    self[:image_file_name] = "#{id}.img"
  end

  def node_modules_with_dependencies
    module_list = node_modules + node.node_modules + node_template.node_modules.where(required: true)
    module_list += module_list.flatten.uniq.map { |m| m.scope_to_node_instance(self).dependant_modules_with_recursion }
    module_list.flatten.uniq
  end

  def primary
    id == node.primary_instance_id
  end
  alias primary? primary

  def reset_key
    self.key = SecureRandom.urlsafe_base64(Powernode.config.instance_key_length)
  end

  def uuid_partition
    uuid = UUIDTools::UUID.parse(id)
    sprintf('%04d/%02d/%02d/%02d/%02d', uuid.timestamp.year,
                                        uuid.timestamp.month,
                                        uuid.timestamp.day,
                                        uuid.timestamp.hour,
                                        uuid.timestamp.min)
  end

  def to_s
    name
  end

  private

  def generate_image_checksum
    self.image_checksum = Digest::SHA2.new(Powernode.config.checksum_bitlength || 256).hexdigest(File.binread(image.queued_for_write[:original].path))
  end
end
