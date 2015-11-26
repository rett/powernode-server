class NodeArchitecture < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  COMPONENTS = %w[kernel ramdisk image]

  belongs_to :account
  has_many :node_platforms
  has_many :pages, as: :pageable, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true, uniqueness: true

  NodeArchitecture::COMPONENTS.each do |component|
    has_attached_file component, path: "#{Powernode.config.arch_dir}/:uuid_partition/:#{component}_file_name", default_url: '', url: ''
    validates_attachment_content_type component, content_type: /.*/
    self.send("after_#{component}_post_process", "generate_#{component}_checksum".to_sym)
    define_method("#{component}_file_name=".to_sym) do |_|
      self[:id] ||= UUIDTools::UUID.timestamp_create.to_s
      self["#{component}_file_name".to_sym] = "#{id}.#{component}"
    end
    define_method("generate_#{component}_checksum".to_sym) do
      self["#{component}_checksum".to_sym] = Digest::SHA2.new(Powernode.config.checksum_bitlength || 256).hexdigest(File.binread(self.send(component).queued_for_write[:original].path))
    end
    private "generate_#{component}_checksum".to_sym
  end

  def to_s
    name
  end

  def uuid_partition
    sprintf('%04d/%02d/%02d/%02d/%02d', uuid.timestamp.year,
            uuid.timestamp.month,
            uuid.timestamp.day,
            uuid.timestamp.hour,
            uuid.timestamp.min)
  end
end
