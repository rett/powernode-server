class Plan < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include ActionView::Helpers::NumberHelper
  include Powernode::UUIDExtensions

  belongs_to :account
  has_many :accounts

  attr_readonly :amount,
                :currency,
                :interval,
                :interval_count,
                :trial_period_days

  serialize :default_roles, JSON

  default_scope { order('name ASC') }

  scope :enabled,   -> { where(enabled: true) }
  scope :available, -> { enabled.where(public: true) }
  scope :featured,  -> { available.where(featured: true) }
  scope :popular,   -> { featured.where(id: Account.group('plan_id').order('count(*) desc').limit(5).count.keys) }

  validates :id, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :default_roles, :node_limit, :instance_limit, :user_limit, presence: true
  validates :amount, :interval, :interval_count, presence: true
  validates_numericality_of :interval_count, only_integer: true, greater_than: 0
  validates_inclusion_of :interval, in: %w[day month]
  validates_presence_of :name

  before_destroy :destroy_stripe_plan
  before_save :update_stripe_plan
  before_save :validate_default_roles

  after_initialize do
    self.id ||= UUIDTools::UUID.timestamp_create.to_s
  end

  def most_popular?
    Plan.popular.first == self
  end

  def stripe_plan
    @stripe_plan ||= StripePlan.new(self)
  end

  def statement_descriptor
    attribute(:statement_descriptor).blank? ? nil : attribute(:statement_descriptor)
  end

  def to_s
    name
  end

  private

  def destroy_stripe_plan
    stripe_plan.destroy!
  end

  def update_stripe_plan
    stripe_plan.update!
  end

  def validate_default_roles
    self.default_roles.delete_if { |role| !User::ROLES.include?(role) }
  end
end
