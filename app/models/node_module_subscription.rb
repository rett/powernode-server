class NodeModuleSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :node
  belongs_to :node_module
  belongs_to :node_module_copy_path
  has_many :node_modules, dependent: :destroy

  validates :id, uniqueness: true

  def create_dependant_module!(node_instance = nil)
    if node_module.configurable? && node_module.node_module_category.config_category
      if node.node_modules.where(node_module_subscription_id: self, node_instance_id: node_instance).size == 0
        node.node_modules << node_modules.build(account: node.account, node_instance: node_instance)
      end
    end
  end
end
