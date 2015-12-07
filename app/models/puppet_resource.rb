class PuppetResource < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :account
  belongs_to :puppet_module

  default_scope { order('name ASC') }

  scope :enabled, -> { where(enabled: true) }

  validates :id, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z0-9._-]*\z/ }, presence: true
  validates :path, format: { with: /\A\/[\w\/_-]*\z/ }, allow_blank: true
  validates_uniqueness_of :name, scope: :puppet_module_id

  delegate :account, :account_id, to: :puppet_module

  def path_name
    File.join('${UNION}', Powernode.config.puppet_cache_dir, 'modules', puppet_module.name, path, name)
  end

  def to_s
    name
  end
end
