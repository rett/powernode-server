class NodeTemplateModuleSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :node_module
  belongs_to :node_template

  validates :id, uniqueness: true
end
