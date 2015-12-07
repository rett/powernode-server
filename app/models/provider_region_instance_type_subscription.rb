class ProviderRegionInstanceTypeSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :provider_region
  belongs_to :provider_instance_type

  validates :id, uniqueness: true
end
