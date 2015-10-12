class NodeModulePuppetModuleSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :node_module
  belongs_to :puppet_module

  validates :id, uniqueness: true
end
