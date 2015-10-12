class NodeArchitecturesController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @node_architecture if @node_architecture.try(:persisted?) }

  respond_to :html

  def index
    @search = @node_architectures.search(params[:q])
    @node_architectures = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @node_architectures
  end

  def show
    @details = @node_architecture.details
    respond_with @node_architecture
  end

  def new
    respond_with @node_architecture
  end

  def create
    @node_architecture = NodeArchitecture.create(node_architecture_params.merge({ account_id: @current_account.id }))
    respond_with @node_architecture
  end

  def update
    @node_architecture.update_attributes(node_architecture_params)
    respond_with @node_architecture
  end

  def download_image
    respond_to do |format|
      format.html do
        if can?(:read, @node_architecture)
          send_file(@node_architecture.image.path, type: 'application/octet-stream', filename: @node_architecture.name + '.img')
        else
          render nothing: true, status: :not_found
        end
      end
    end
  end

  private

  def node_architecture_params
    permitted_params  = [:architecture,
                         :description,
                         :details,
                         :enabled,
                         :name,
                         :kernel,
                         :ramdisk]
    permitted_params += [:public] if can?(:manage, NodeArchitecture)
    params.require(:node_architecture).permit(*permitted_params)
  end
end
