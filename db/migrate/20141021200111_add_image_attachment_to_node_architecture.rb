class AddImageAttachmentToNodeArchitecture < ActiveRecord::Migration
  def change
    add_attachment :node_architectures,                           :image
    add_column     :node_architectures,                           :image_checksum,              :string,  default: '',      null: false
  end
end
