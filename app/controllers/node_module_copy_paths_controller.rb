class NodeModuleCopyPathsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @node_module_copy_path if @node_module_copy_path.try(:persisted?) }

  respond_to :html

  def index
    @search = @node_module_copy_paths.search(params[:q])
    @node_module_copy_paths = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @node_module_copy_paths
  end

  def show
    respond_with @node_module_copy_path
  end

  def new
    respond_with @node_module_copy_path
  end

  def create
    @node_module_copy_path = NodeModuleCopyPath.create(node_module_copy_path_params.merge({ account_id: @current_account.id }))
    respond_with @node_module_copy_path
  end

  def destroy
    @node_module_copy_path.destroy
    respond_with @node_module_copy_path
  end

  def update
    @node_module_copy_path.update_attributes(node_module_copy_path_params)
    respond_with @node_module_copy_path
  end

  private

  def node_module_copy_path_params
    permitted_params  = [{ pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy] },
                         :description,
                         :enabled,
                         :name,
                         :path]
    permitted_params += [:public] if can?(:manage, NodeModuleCopyPath)
    params.require(:node_module_copy_path).permit(*permitted_params)
  end
end
