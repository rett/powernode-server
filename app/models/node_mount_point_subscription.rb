class NodeMountPointSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :node_instance
  belongs_to :node_mount_point

  validates :id, uniqueness: true
end
