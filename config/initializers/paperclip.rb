require 'paperclip/media_type_spoof_detector'

module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
    end
  end
end

Paperclip::Attachment.default_options.merge!(
  s3_credentials: {
    bucket: Powernode.config.s3_bucket,
    access_key_id: Powernode.config.s3_access_key,
    secret_access_key: Powernode.config.s3_secret_key
  },
  s3_permissions: {
    original: :private
  }
)

Paperclip.interpolates :uuid_partition do |attachment, _|
  attachment.instance.uuid_partition
end

Paperclip.interpolates :data_file_name  do |attachment, _|
  attachment.instance.data_file_name
end

Paperclip.interpolates :image_file_name  do |attachment, _|
  attachment.instance.image_file_name
end

Paperclip.interpolates :kernel_file_name  do |attachment, _|
  attachment.instance.kernel_file_name
end

Paperclip.interpolates :ramdisk_file_name  do |attachment, _|
  attachment.instance.ramdisk_file_name
end
