class NodeModulePuppetModuleSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :node_module
  belongs_to :puppet_module

  validates :id, uniqueness: true
end
