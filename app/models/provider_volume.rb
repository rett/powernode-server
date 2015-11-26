class ProviderVolume < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  RAID_LEVELS = [0, 1]

  belongs_to :account
  belongs_to :mount_script, class_name: 'NodeScript'
  belongs_to :node_instance
  belongs_to :node_module
  belongs_to :provider_region
  belongs_to :provider_volume_type
  has_many :pages, as: :pageable, dependent: :destroy
  has_many :provider_volume_members, dependent: :destroy
  has_many :provider_volume_snapshots, dependent: :destroy

  accepts_nested_attributes_for :pages, allow_destroy: true

  attr_readonly :provider_id, :raid, :raid_level, :size

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :account, presence: true
  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-z][a-zA-Z0-9_]*\z/ }, presence: true
  validates :provider_region, presence: true
  validates :provider_volume_type, presence: true
  validates_uniqueness_of :name, scope: :account_id

  before_create do
    self.status ||= 'pending'
  end

  before_save do
    self.status.downcase! if status_changed?
  end

  def actual_size
    size * (raid && raid_level == 0 ? 2 : 1)
  end

  alias_method :orig_mount_script, :mount_script
  def mount_script
    custom_mount_script && orig_mount_script ? orig_mount_script : provider_volume_type.try(:mount_script)
  end

  def mount_script_id
    mount_script.try(:id)
  end

  def to_s
    name
  end
end
