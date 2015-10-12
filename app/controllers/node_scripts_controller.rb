class NodeScriptsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @node_script if @node_script.try(:persisted?) }

  respond_to :html

  def index
    @search = @node_scripts.search(params[:q])
    @node_scripts = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @node_scripts
  end

  def show
    @details = @node_script.details
    respond_with @node_script
  end

  def new
    respond_with @node_script
  end

  def create
    @node_script = NodeScript.create(node_script_params.merge({ account_id: @current_account.id }))
    respond_with @node_script
  end

  def update
    @node_script.update_attributes(node_script_params)
    respond_with @node_script
  end

  def destroy
    @node_script.destroy
    respond_with @node_script
  end

  private

  def node_script_params
    permitted_params  = [:data,
                         :description,
                         :details,
                         :enabled,
                         :name,
                         :variety]
    permitted_params += [:public] if can?(:manage, NodeScript)
    params.require(:node_script).permit(*permitted_params)
  end
end
