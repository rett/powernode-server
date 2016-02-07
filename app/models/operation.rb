class Operation < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  STATUSES = %w[abort complete failed pending running]

  belongs_to :account
  belongs_to :operable, polymorphic: true

  serialize :events, JSON
  serialize :options, JSON

  default_scope { order('scheduled_at DESC') }

  scope :complete,  -> { where(status: 'complete') }
  scope :failed,    -> { where(status: 'failed' ) }
  scope :pending,   -> { where(status: 'pending') }
  scope :scheduled, -> { where.not(status: %w[complete failed]) }

  validates :account, presence: true
  validates :command, presence: true
  validates :id, uniqueness: true
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates_inclusion_of :status, in: Operation::STATUSES

  before_validation do
    self.icon = 'cog' if self.icon.empty?
    self.progress ||= 0
    self.progress = 100 if progress > 100
    self.scheduled_at ||= Time.now
    self.status ||= 'pending'
  end

  before_save do
    self.status.downcase if status_changed?
  end

  Operation::STATUSES.each do |s|
    define_method(s + '?') do
      self.status == s
    end
    define_method(s + '!') do
      self.status = s
      self.save
    end
  end
end
