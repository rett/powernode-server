class PageResource < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true
  validates_uniqueness_of :name, scope: :page_id

  delegate :account, :account_id, to: :page
  delegate :enabled, to: :page
  delegate :public,  to: :page

  has_attached_file :data,
                    bucket: Powernode.config.s3_bucket,
                    path: 'page_resources/:uuid_partition/:id-:style.:extension',
                    storage: :s3,
                    styles: { medium: '800x500>', thumb: '160x160>' },
                    url: ':s3_domain_url'

  validates_attachment_content_type :data, content_type: /\Aimage\/.*\Z/
  validates_with AttachmentSizeValidator, attributes: :data, less_than: 30.megabytes

  after_data_post_process :generate_data_checksum

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
