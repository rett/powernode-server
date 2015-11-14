class Account < ActiveRecord::Base
  include AASM
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :agent
  belongs_to :owner, class_name: 'User'
  belongs_to :plan
  has_many :account_delegations, dependent: :destroy
  has_many :agents, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :nodes, dependent: :destroy
  has_many :node_instances, through: :nodes
  has_many :node_architectures, dependent: :destroy
  has_many :node_module_categories, dependent: :destroy
  has_many :node_module_copy_paths, dependent: :destroy
  has_many :node_modules, dependent: :destroy
  has_many :node_mount_points, dependent: :destroy
  has_many :node_platforms, dependent: :destroy
  has_many :node_scripts, dependent: :destroy
  has_many :node_templates, dependent: :destroy
  has_many :operations, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :plans, dependent: :destroy
  has_many :providers, dependent: :destroy
  has_many :provider_availability_zones, dependent: :destroy
  has_many :provider_connections, dependent: :destroy
  has_many :provider_instance_types, dependent: :destroy
  has_many :provider_networks, dependent: :destroy
  has_many :provider_network_subnets, dependent: :destroy
  has_many :provider_regions, dependent: :destroy
  has_many :provider_volumes, dependent: :destroy
  has_many :provider_volume_members, dependent: :destroy
  has_many :provider_volume_types, dependent: :destroy
  has_many :puppet_modules, dependent: :destroy
  has_many :users, dependent: :destroy

  attr_accessor :stripe_token

  delegate :email,          to: :owner, allow_nil: true
  delegate :node_limit,     to: :plan,  allow_nil: true
  delegate :instance_limit, to: :plan,  allow_nil: true
  delegate :user_limit,     to: :plan,  allow_nil: true

  validates :id, uniqueness: true
  validates :name, presence: true
  validates :plan, presence: true

  after_initialize do
    self.id ||= UUIDTools::UUID.timestamp_create.to_s
    self.agent ||= Agent.primary.last
    self.encryption_key ||= SecureRandom.hex(Powernode.config.encryption_key_length)
  end

  before_destroy :destroy_stripe_customer
  before_save :update_stripe_customer

  aasm column: :state do
    state :trialing, initial: true
    state :active
    state :delinquent
    event :active do
      transitions from: :delinquent, to: :active
      transitions from: :trialing, to: :active
    end
    event :delinquent do
      transitions from: :active, to: :delinquent
    end
  end

  def disabled
    !enabled
  end
  alias disabled? disabled

  def enabled
    active? || trialing?
  end
  alias enabled? enabled

  def self.enforce_limits(limits = {})
    class_attribute :subscription_limits
    self.subscription_limits = limits
    limits.each do |name, meth|
      define_method("reached_#{name}?") do
        plan.respond_to?(name) && plan.send(name) <= meth.call(self)
      end
    end
  end

  enforce_limits(user_limit: Proc.new { |a| a.users.count },
                 node_limit: Proc.new { |a| a.nodes.count },
                 instance_limit: Proc.new { |a| a.node_instances.count })

  def qualifies_for?(plan)
    self.class.subscription_limits.map do |name, meth|
      limit = plan.send(name)
      !limit || (meth.call(self) <= limit)
    end.all?
  end

  def requires_billing_info?
    plan.amount > 0 && disabled?
  end

  def stripe_customer
    @stripe_customer ||= StripeCustomer.new(self)
  end

  def to_s
    name
  end

  private

  def destroy_stripe_customer
    stripe_customer.destroy!
  end

  def update_stripe_customer
    stripe_customer.update! if persisted?
  end
end
