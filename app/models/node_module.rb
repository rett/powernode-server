class NodeModule < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  VARIETIES = %w[config instance subscription]

  belongs_to :account
  belongs_to :build_script, class_name: 'NodeScript'
  belongs_to :node_instance
  belongs_to :node_module_category
  belongs_to :node_platform
  belongs_to :node_module_subscription
  has_one  :parent_module, class_name: 'NodeModule', through: :node_module_subscription, source: :node_module, dependent: :destroy
  has_many :node_module_subscriptions, dependent: :destroy
  has_many :child_modules, class_name: 'NodeModule', through: :node_module_subscriptions, source: :node_modules, dependent: :destroy
  has_many :node_module_dependencies, dependent: :destroy
  has_many :dependant_modules, class_name: 'NodeModule', through: :node_module_dependencies, source: :node_module_dependency, dependent: :destroy
  has_many :node_template_module_subscriptions, dependent: :destroy
  has_many :node_templates, through: :node_template_module_subscriptions, dependent: :destroy
  has_many :nodes, through: :node_module_subscriptions, dependent: :destroy
  has_many :node_module_puppet_module_subscriptions
  has_many :operations, as: :operable
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :puppet_modules, through: :node_module_puppet_module_subscriptions

  accepts_nested_attributes_for :pages, allow_destroy: true

  attr_readonly :variety

  default_scope { order('name ASC') }

  scope :enabled,  -> { where(enabled: true) }
  scope :required, -> { enabled.where(required: true) }

  serialize :mask, JSON
  serialize :package_spec, JSON
  serialize :spec, JSON
  serialize :dependency_spec, JSON

  validates :account, presence: true
  validates :data_file_name, allow_blank: true, format: { with: /\A[a-z0-9.-]*\z/ }, uniqueness: true
  validates :id, uniqueness: true
  validates :name, allow_blank: true, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }, presence: true
  validates :node_module_category, presence: true
  validates :node_platform, presence: true
  validates_inclusion_of :variety, in: NodeModule::VARIETIES
  validates_uniqueness_of :name, scope: :node_platform_id
  validates_numericality_of :priority, only_integer: true,
                            greater_than_or_equal_to: Powernode.config.module_priority_range[0],
                            less_than_or_equal_to: Powernode.config.module_priority_range[1]

  validate :reject_modifying_spec, on: :update, if: :lock_spec?

  before_validation(on: :create) { self.variety = node_module_category.try(:variety) }
  before_validation :encode_specs
  before_destroy :destroy_files

  before_save :remove_invalid_template_subscriptions

  acts_as_versioned if_changed: [:data_file_name]

  NodeModule.column_names.reject { |column| column =~ /\Adata_\w+\z/ }.each { |data_column| self.non_versioned_columns << data_column }

  has_attached_file :data,
                    default_url: '',
                    url: '',
                    path: "#{Powernode.config.module_dir}/:uuid_partition/:data_file_name",
                    preserve_files: true

  validates_attachment_content_type :data, content_type: /.*/

  after_data_post_process :generate_data_checksum

  NodeModule::VARIETIES.each do |v|
    scope "#{v}_variety".to_sym, -> { where(variety: v) }
    define_method("#{v}_variety?") { variety == v }
  end

  alias_method :orig_build_script, :build_script
  def build_script
    custom_build_script && orig_build_script ? orig_build_script : node_platform.try(:build_script)
  end

  def build_script_id
    build_script.try(:id)
  end

  def copy_path
    @node_instance.node.node_module_subscription(self).node_module_copy_path.try(:path) if @node_instance && @node_instance.node.node_module_subscription(self)
  end

  def data_file_name=(name)
    self.id ||= UUIDTools::UUID.timestamp_create.to_s
    self[:data_file_name] = "#{id}-#{data_file_version(version ? version + 1 : 1)}.#{Powernode.config.module_extension}"
  end

  def data_file_version(ver = version)
    sprintf("%0#{Powernode.config.module_version_padding}d", ver)
  end

  def dependant_modules_with_recursion(dependant_module_list = [])
    dependant_modules.each do |dependant_module|
      if !dependant_module_list.include?(dependant_module) && dependant_module.enabled? && (@node.present? ? @node.node_module_subscription(self).try(:enabled?) : true)
        dependant_module_list << dependant_module
        dependant_module.dependant_modules_with_recursion(dependant_module_list)
      end
    end
    dependant_module_list.flatten.uniq.select { |m| m != self }
  end

  def effective_priority
    ((node_module_category.priority * Powernode.config.module_priority_category_multiplier) + priority)
  end

  def enabled
    if @node_instance
      @node_instance.node.node_module_subscription(self).try(:enabled?)
    else
      node_module_subscription ? node_module_subscription.enabled? : self[:enabled]
    end
  end
  alias :enabled? :enabled

  def info
    <<-EOF.strip_heredoc
      name=#{name}
      init_restart=#{init_restart}
      init_start=#{init_start}
      init_stop=#{init_stop}
      priority=#{effective_priority.to_s.rjust(Powernode.config.module_priority_places, '0')}
      reboot=#{reboot_required}
      version=#{version}
      copy_path=#{copy_path}
    EOF
  end

  def ready
    status == 'ready'
  end
  alias :ready? :ready

  def spec
    parent_module.present? ? parent_module.dependency_spec : self[:spec]
  end

  def scope_to_node_instance(node_instance)
    @node_instance = node_instance
    self
  end

  def to_s
    name
  end

  def name
    if parent_module && config_variety?
      "#{parent_module} for #{node_module_subscription(parent_module).node}"
    elsif parent_module && instance_variety?
      "#{parent_module} for #{node_instance}"
    else
      self[:name]
    end
  end

  alias_method :orig_node_module_category, :node_module_category
  def node_module_category
    if orig_node_module_category
      orig_node_module_category
    elsif parent_module && node_instance
      parent_module.node_module_category.instance_category
    elsif parent_module
      parent_module.node_module_category.config_category
    end
  end

  alias_method :orig_node_platform, :node_platform
  def node_platform
    if orig_node_platform
      orig_node_platform
    elsif parent_module
      parent_module.orig_node_platform
    end
  end

  def provisional
    node_module_subscription.present? ? node_module_subscription.node_module.provisional : self[:provisional]
  end
  alias :provisional? :provisional

  def status
    bitlength = Powernode.config.checksum_bitlength || 256
    if data_file_name.present?
      file = File.join(Powernode.config.module_dir, uuid_partition, data_file_name)
      if File.exist?(file) && data_file_size == File.size(file) && data_checksum == Digest::SHA2.new(bitlength).hexdigest(File.binread(file))
        'ready'
      else
        'error'
      end
    else
      'unavailable'
    end
  end

  def uuid_partition
    sprintf('%04d/%02d/%02d/%02d/%02d', uuid.timestamp.year,
                                        uuid.timestamp.month,
                                        uuid.timestamp.day,
                                        uuid.timestamp.hour,
                                        uuid.timestamp.min)
  end

  def version_delete!(ver)
    if ver < version && (old_version = versions.find_by(version: ver)) && old_version.data_file_name
      old_file = File.join(Powernode.config.module_dir, uuid_partition, old_version.data_file_name)
      begin
        FileUtils.rm(old_file)
      rescue => e
        logger.error "Exception: #{e}"
      end
      old_version.delete unless File.exist?(old_file)
      self.reload
    end
  end

  def version_purge!(ver)
    versions.select { |v| v.version <= ver && v.version < version }.each do |old_version|
      version_delete!(old_version.version)
    end
  end

  def version_restore!(ver)
    self.data_file_name = true
    if (old_version = versions.find_by(version: ver)) && old_version.data_checksum
      old_file = File.join(Powernode.config.module_dir, uuid_partition, old_version.data_file_name)
      new_file = File.join(Powernode.config.module_dir, uuid_partition, data_file_name)
      begin
        FileUtils.ln(old_file, new_file)
      rescue => e
        logger.error "Exception: #{e}"
      end
      if File.exist?(new_file)
        self.data_checksum = Digest::SHA2.new(Powernode.config.checksum_bitlength || 256).hexdigest(File.binread(new_file))
        self.save
      end
    end
  end

  def mask_text
    decode_spec_text(mask)
  end

  def effective_mask
    final_mask = []
    if @node_instance
      @node_instance.node_modules_with_dependencies.each do |node_module|
        if node_module != self && node_module.effective_priority > effective_priority
          if node_module.immutable?
            final_mask << node_module.spec
            final_mask << node_module.dependency_spec
          end
          final_mask << node_module.mask
        end
      end
    end
    final_mask.sort.flatten.uniq
  end

  def rsync_spec
    @rsync_spec ||= (decode_spec(effective_mask).map { |l| "- #{l}\n" } +
                     decode_spec(spec).map { |l| "+ #{l}\n" }).join + "- *\n"
  end

  def package_spec_text
    decode_spec_text(package_spec)
  end

  def spec_text
    decode_spec_text(spec)
  end

  def dependency_spec_text
    decode_spec_text(dependency_spec)
  end

  private

  def destroy_files
    versions.each do |v|
      if v.data_file_name.present?
        data_file = File.join(Powernode.config.module_dir, uuid_partition, v.data_file_name)
        begin
          FileUtils.rm(data_file) if File.exist?(data_file)
        rescue => e
          logger.error "Exception: #{e}"
        end
      end
    end
  end

  def generate_data_checksum
    self.data_checksum = Digest::SHA2.new(Powernode.config.checksum_bitlength || 256).hexdigest(File.binread(data.queued_for_write[:original].path))
  end

  def decode_spec(spec)
    spec.is_a?(Array) ? spec.map { |m| Base64.decode64(m) } : spec
  end

  def decode_spec_text(spec)
    spec.is_a?(Array) ? decode_spec(spec).map { |m| m + "\n" }.join : spec
  end

  def encode_spec(attribute)
    attribute.is_a?(String) ? attribute.split(/\r?\n/).map(&:strip).uniq.sort.delete_if(&:empty?).map { |l| Base64.encode64(l) } : attribute
  end

  def encode_specs
    self[:dependency_spec] = encode_spec(dependency_spec) if dependency_spec_changed?
    self[:package_spec] = encode_spec(package_spec) if package_spec_changed?
    self[:spec] = encode_spec(spec) if spec_changed?
    self[:mask] = encode_spec(mask) if mask_changed?
  end

  def reject_modifying_spec
    errors[:spec] << 'cannot be changed while spec is locked!' if self.spec_changed?
  end

  def remove_invalid_template_subscriptions
    self.node_templates -= node_templates.where.not(account_id: account_id) unless public?
  end
end
