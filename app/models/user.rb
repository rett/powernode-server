class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  ROLES = %w[global_admin
             account_admin
             account_manager
             agent_admin
             agent_manager
             invitation_admin
             invitation_manager
             page_admin
             page_manager
             page_publisher
             plan_admin
             plan_manager
             node_admin
             node_manager
             node_module_admin
             node_module_manager
             node_module_publisher
             node_platform_admin
             node_platform_manager
             node_platform_publisher
             node_script_admin
             node_script_manager
             node_script_publisher
             node_template_admin
             node_template_manager
             node_template_publisher
             provider_connection_admin
             provider_connection_manager
             provider_admin
             provider_manager
             puppet_admin
             puppet_manager
             puppet_publisher
             user_admin
             user_manager]

  belongs_to :account
  has_many :account_delegations, dependent: :destroy
  has_many :accounts, through: :account_delegations
  has_one  :invitation

  default_scope { order('name ASC') }

  attr_accessor :invitation_id,
                :plan_id,
                :stripe_card,
                :stripe_card_cvc,
                :stripe_card_exp_month,
                :stripe_card_exp_year,
                :stripe_card_last4,
                :stripe_card_number,
                :stripe_token

  scope :enabled, -> { where(enabled: true) }

  devise :async,
         :confirmable,
         :database_authenticatable,
         :lockable,
         :recoverable,
         :registerable,
         :rememberable,
         :timeoutable,
         :trackable,
         :validatable


  serialize :preferences, JSON
  serialize :roles, JSON

  validates :invitation, presence: true, on: :create, unless: 'account'
  validates :account, presence: true
  validates :email, presence: true, uniqueness: true
  validates :id, uniqueness: true
  validates :name, presence: true
  validates_inclusion_of :locale, in: I18n.available_locales.map(&:to_s)

  after_initialize do
    self.id ||= UUIDTools::UUID.timestamp_create.to_s
    self.locale ||= 'en'
  end

  before_validation on: :create do
    unless account.present?
      create_account(name: name,
                     owner_id: id,
                     plan: Plan.available.find_by(id: plan_id),
                     stripe_card: stripe_card,
                     stripe_card_last4: stripe_card_last4,
                     stripe_card_exp_month: stripe_card_exp_month,
                     stripe_card_exp_year: stripe_card_exp_year,
                     stripe_token: stripe_token)
      self.invitation = Invitation.find_by(id: invitation_id)
      self.invitation ||= Invitation.find_by(recipient: email)
      self.invitation ||= Invitation.available.first
      self.roles = account.plan.default_roles
    end
  end

  after_create do
    invitation.destroy if invitation.present?
    account.stripe_customer.update!
  end

  before_save do
    self.roles = roles.flatten.uniq.map(&:to_s).reject { |r| !ROLES.include?(r) }
  end

  def self.available_default_roles
    ROLES.select { |r| r[/\A\w+(_manager|_publisher)\z/] }
  end

  def admin_roles
    roles.select { |r| r[/\A\w+_admin\z/] }
  end

  def manager_roles
    roles.select { |r| r[/\A\w+_manager\z/] }
  end

  def publisher_roles
    roles.select { |r| r[/\A\w+_publisher\z/] }
  end

  def has_any_role?(*roles)
    roles.select { |r| roles.include?(r.to_s) }.size > 0
  end

  def has_role?(role)
    roles.include?(role.to_s)
  end

  def to_s
    name
  end
end
