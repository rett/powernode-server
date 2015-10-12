class ProviderNetworksController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider_network if @provider_network.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @provider_networks.search(params[:q])
    @provider_networks = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @provider_networks
  end

  def show
    @details = @provider_network.details
    respond_with @provider_network
  end

  def new
    respond_with @provider_network
  end

  def create
    @provider_network = ProviderNetwork.create(provider_network_params.merge({ account_id: @current_account.id }))
    respond_with @provider_network
  end

  def update
    @provider_network.update_attributes(provider_network_params)
    respond_with @provider_network
  end

  def destroy
    @provider_network.destroy
    respond_with @provider_network
  end

  private

  def load_objects
    @available_provider_regions = ProviderRegion.accessible_by(@current_ability, :use)
  end

  def provider_network_params
    permitted_params  = [:description,
                         :details,
                         :dns1,
                         :dns2,
                         :entity,
                         :name,
                         :network,
                         :provider_region_id]
    params.require(:provider_network).permit(*permitted_params)
  end
end
