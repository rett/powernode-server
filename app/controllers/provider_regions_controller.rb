class ProviderRegionsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider_region if @provider_region.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]
  before_action :filter_provider_instance_types, only: [:create, :update]

  respond_to :html

  def index
    @search = @provider_regions.search(params[:q])
    @provider_regions = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @provider_regions
  end

  def show
    respond_with @provider_region
  end

  def new
    respond_with @provider_region
  end

  def create
    @provider_region = ProviderRegion.create(provider_region_params.merge({ account_id: @current_account.id }))
    respond_with @provider_region
  end

  def update
    @provider_region.update_attributes(provider_region_params)
    respond_with @provider_region
  end

  def destroy
    @provider_region.destroy
    respond_with @provider_region
  end

  private

  def filter_provider_instance_types
    params[:provider_region].try(:[], :provider_instance_type_ids).delete_if { |t| !@available_provider_instance_types.map(&:id).map(&:to_s).include?(t) }
  end

  def load_objects
    @available_provider_instance_types = ProviderInstanceType.accessible_by(@current_ability, :use)
    @available_provider_volume_types = ProviderVolumeType.accessible_by(@current_ability, :use)
    @available_providers = Provider.accessible_by(@current_ability, :use)
  end

  def provider_region_params
    permitted_params  = [{ pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy],
                           provider_instance_type_ids: [],
                           provider_volume_type_ids: [] },
                         :availability_zones,
                         :description,
                         :enabled,
                         :endpoint_url,
                         :kernel_image,
                         :machine_image,
                         :name,
                         :provider_id,
                         :ramdisk_image,
                         :region]
    permitted_params += [:public] if can?(:manage, ProviderRegion)
    params.require(:provider_region).permit(*permitted_params)
  end
end
