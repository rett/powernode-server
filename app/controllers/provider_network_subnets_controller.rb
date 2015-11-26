class ProviderNetworkSubnetsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider_network_subnet if @provider_network_subnet.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @provider_network_subnets.search(params[:q])
    @provider_network_subnets = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @provider_network_subnets
  end

  def show
    respond_with @provider_network_subnet
  end

  def new
    respond_with @provider_network_subnet
  end

  def create
    @provider_network_subnet = ProviderNetworkSubnet.create(provider_network_subnet_params.merge({ account_id: @current_account.id }))
    respond_with @provider_network_subnet
  end

  def update
    @provider_network_subnet.update_attributes(provider_network_subnet_params)
    respond_with @provider_network_subnet
  end

  def destroy
    @provider_network_subnet.destroy
    respond_with @provider_network_subnet
  end

  private

  def load_objects
    @available_provider_networks = ProviderNetwork.accessible_by(@current_ability, :use)
    @available_availability_zones = ProviderAvailabilityZone.accessible_by(@current_ability, :use)
  end

  def provider_network_subnet_params
    permitted_params  = [{ pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy] },
                         :description,
                         :entity,
                         :name,
                         :network,
                         :provider_availability_zone_id,
                         :provider_network_id]
    params.require(:provider_network_subnet).permit(*permitted_params)
  end
end
