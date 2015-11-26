class ProviderAvailabilityZonesController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider_availability_zone if @provider_availability_zone.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @provider_availability_zones.search(params[:q])
    @provider_availability_zones = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @provider_availability_zones
  end

  def show
    respond_with @provider_availability_zone
  end

  def new
    respond_with @provider_availability_zone
  end

  def create
    @provider_availability_zone = ProviderAvailabilityZone.create(provider_availability_zone_params.merge({ account_id: @current_account.id }))
    respond_with @provider_availability_zone
  end

  def update
    @provider_availability_zone.update_attributes(provider_availability_zone_params)
    respond_with @provider_availability_zone
  end

  def destroy
    @provider_availability_zone.destroy
    respond_with @provider_availability_zone
  end

  private

  def load_objects
    @available_provider_regions = ProviderRegion.accessible_by(@current_ability, :use)
  end

  def provider_availability_zone_params
    permitted_params  = [{ pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy] },
                         :description,
                         :enabled,
                         :entity,
                         :name,
                         :provider_region_id]
    permitted_params += [:public] if can?(:manage, ProviderRegion)
    params.require(:provider_availability_zone).permit(*permitted_params)
  end
end
