class ProviderInstanceTypesController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider_instance_type if @provider_instance_type.try(:persisted?) }

  respond_to :html

  def index
    @search = @provider_instance_types.search(params[:q])
    @provider_instance_types = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @provider_instance_types
  end

  def show
    respond_with @provider_instance_type
  end

  def new
    respond_with @provider_instance_type
  end

  def create
    @provider_instance_type = ProviderInstanceType.create(provider_instance_type_params.merge({ account_id: @current_account.id }))
    respond_with @provider_instance_type
  end

  def update
    @provider_instance_type.update_attributes(provider_instance_type_params)
    respond_with @provider_instance_type
  end

  private

  def provider_instance_type_params
    permitted_params  = [{ pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy] },
                         :name,
                         :description,
                         :enabled]
    permitted_params += [:public] if can?(:manage, ProviderInstanceType)
    params.require(:provider_instance_type).permit(*permitted_params)
  end
end
