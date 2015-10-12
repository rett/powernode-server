require 'paperclip/media_type_spoof_detector'

module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
    end
  end
end

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
