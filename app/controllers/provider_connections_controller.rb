class ProviderConnectionsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @provider_connection if @provider_connection.try(:persisted?) }

  respond_to :html

  def index
    @search = @provider_connections.search(params[:q])
    @provider_connections = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @provider_connections
  end

  def show
    @details = @provider_connection.details
    respond_with @provider_connection
  end

  def new
    respond_with @provider_connection
  end

  def create
    @provider_connection = ProviderConnection.create(provider_connection_params.merge({ account_id: @current_account.id }))
    respond_with @provider_connection
  end

  def update
    @provider_connection.update_attributes(provider_connection_params)
    respond_with @provider_connection
  end

  def destroy
    @provider_connection.destroy
    respond_with @provider_connection
  end

  private

  def provider_connection_params
    permitted_params  = [:access_key,
                         :description,
                         :details,
                         :enabled,
                         :name,
                         :provider_id,
                         :secret_key,
                         :tenant]
    params.require(:provider_connection).permit(*permitted_params)
  end
end
