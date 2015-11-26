class PuppetModule < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  has_many :node_module_puppet_module_subscriptions
  has_many :node_modules, through: :node_module_puppet_module_subscriptions
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :puppet_resources, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true
  accepts_nested_attributes_for :puppet_resources, allow_destroy: true

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-z][a-zA-Z0-9_]*\z/ }, presence: true, uniqueness: true

  has_attached_file :data,
                    default_url: '',
                    url: '',
                    path: "#{Powernode.config.puppet_dir}/:uuid_partition/:data_file_name"

  validates_attachment_content_type :data, content_type: /.*/

  after_data_post_process :generate_data_checksum

  def data_file_name=(_)
    self.id ||= UUIDTools::UUID.timestamp_create.to_s
    self[:data_file_name] = id
  end

  def encoded_data
    Base64.encode64(File.binread(data.path))
  end

  def path_name
    File.join('${UNION}', Powernode.config.puppet_cache_dir, 'modules')
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

  private

  def generate_data_checksum
    self.data_checksum = Digest::SHA2.new(Powernode.config.checksum_bitlength || 256).hexdigest(File.binread(data.queued_for_write[:original].path))
  end
end
