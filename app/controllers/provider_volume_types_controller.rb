class ProviderVolumeTypesController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider_volume_type if @provider_volume_type.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @provider_volume_types.search(params[:q])
    @provider_volume_types = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @provider_volume_types
  end

  def show
    @details = @provider_volume_type.details
    respond_with @provider_volume_type
  end

  def new
    respond_with @provider_volume_type
  end

  def create
    @provider_volume_type = ProviderVolumeType.create(provider_volume_type_params.merge({ account_id: @current_account.id }))
    respond_with @provider_volume_type
  end

  def update
    @provider_volume_type.update_attributes(provider_volume_type_params)
    respond_with @provider_volume_type
  end

  def destroy
    @provider_volume_type.destroy
    respond_with @provider_volume_type
  end

  private

  def load_objects
    @available_mount_scripts = NodeScript.accessible_by(@current_ability, :use).mount_variety
  end

  def provider_volume_type_params
    permitted_params  = [:description,
                         :details,
                         :name,
                         :mount_script_id]
    permitted_params += [:public] if can?(:manage, ProviderVolumeType)
    params.require(:provider_volume_type).permit(*permitted_params)
  end
end
