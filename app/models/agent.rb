class Agent < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  ROLES = %w[agent poller proxy store]

  belongs_to :account
  has_many :accounts
  has_many :pages, as: :pageable, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  attr_accessor :key, :key_confirmation

  default_scope { order('created_at ASC') }

  scope :enabled, -> { where(enabled: true) }
  scope :primary, -> { where(enabled: true, primary: true) }

  serialize :roles, JSON

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9 ._-]*\z/ }, presence: true, uniqueness: true
  validates :encrypted_key, presence: true
  validates :key, allow_blank: true, confirmation: true, length: Powernode.config.password_length[0]..Powernode.config.password_length[1]

  before_validation do
    self.encrypted_key = SCrypt::Password.create(key + Powernode.config.key_pepper) if key.present?
  end

  before_save do
    self.roles = roles.flatten.uniq.map(&:to_s).sort.reject { |r| !ROLES.include?(r) }
  end

  def authenticate(key)
    enabled? && SCrypt::Password.new(encrypted_key) == key + Powernode.config.key_pepper
  end

  def to_s
    name
  end
end
