class ProviderRegionVolumeTypeSubscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :provider_region
  belongs_to :provider_volume_type

  validates :id, uniqueness: true
end
