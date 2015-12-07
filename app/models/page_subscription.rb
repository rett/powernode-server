class PageSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :pageable, polymorphic: true

  validates :id, uniqueness: true
end
