class ProviderVolumesController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider_volume if @provider_volume.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @provider_volumes.search(params[:q])
    @provider_volumes = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @provider_volumes
  end

  def show
    respond_with @provider_volume
  end

  def new
    respond_with @provider_volume
  end

  def create
    @provider_volume = ProviderVolume.create(provider_volume_params.merge({ account_id: @current_account.id }))
    respond_with @provider_volume
  end

  def update
    @provider_volume.update_attributes(provider_volume_params)
    respond_with @provider_volume
  end

  def destroy
    @provider_volume.destroy
    respond_with @provider_volume
  end

  def update_provider_region_items
    if (provider_region =  ProviderRegion.accessible_by(@current_ability, :use).find_by(id: params[:provider_region_id]))
      @available_provider_volume_types = provider_region.provider_volume_types.accessible_by(@current_ability, :use)
    else
      @available_provider_volume_types = []
    end
  end

  private

  def load_objects
    @available_node_instances = NodeInstance.accessible_by(@current_ability, :use).cloud_variety
    @available_node_modules = NodeModule.accessible_by(@current_ability, :use).subscription_variety
    @available_mount_scripts = NodeScript.accessible_by(@current_ability, :use).mount_variety
    @available_provider_volume_types = ProviderVolumeType.accessible_by(@current_ability, :use)
  end

  def provider_volume_params
    permitted_params  = [{ pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy] },
                         :description,
                         :mount_point,
                         :mount_script_id,
                         :name,
                         :node_instance_id,
                         :node_module_id]
    permitted_params += [:provider_region_id,
                         :raid,
                         :raid_level,
                         :size,
                         :provider_volume_type_id] unless @provider_volume
    params.require(:provider_volume).permit(*permitted_params)
  end
end
