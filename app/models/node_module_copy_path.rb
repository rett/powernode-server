class NodeModuleCopyPath < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :account
  has_many :node_module_subscriptions
  has_many :pages, as: :pageable, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }, presence: true, uniqueness: true
  validates :path, presence: true

  before_save :update_node_module_subscriptions

  def to_s
    name
  end

  private

  def update_node_module_subscriptions
    if public_changed? && !public
      node_module_subscriptions.each do |node_module_subscription|
        if node_module_subscription.node.account_id != account_id
          node_module_subscription.node_module_copy_path_id = nil
          node_module_subscription.save
        end
      end
    end
  end
end
