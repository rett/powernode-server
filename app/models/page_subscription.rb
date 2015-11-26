class PageSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Powernode::UUIDExtensions

  belongs_to :pageable, polymorphic: true

  validates :id, uniqueness: true
end
