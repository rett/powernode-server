class NodeModuleDependency < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :node_module
  belongs_to :node_module_dependency, class_name: 'NodeModule'

  validates :id, uniqueness: true
  validates :node_module, presence: true
  validates :node_module_dependency, presence: true
end
