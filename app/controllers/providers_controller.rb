class ProvidersController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider if @provider.try(:persisted?) }
  respond_to :html

  def index
    @search = @providers.search(params[:q])
    @providers = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @providers
  end

  def show
    respond_with @provider
  end

  def new
    respond_with @provider
  end

  def create
    @provider = Provider.create(provider_params.merge({ account_id: @current_account.id }))
    respond_with @provider
  end

  def update
    @provider.update_attributes(provider_params)
    respond_with @provider
  end

  def destroy
    @provider.destroy
    respond_with @provider
  end

  private

  def provider_params
    permitted_params  = [{ pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy] },
                         :description,
                         :enabled,
                         :name,
                         :variety]
    permitted_params += [:public] if can?(:manage, Provider)
    params.require(:provider).permit(*permitted_params)
  end
end
