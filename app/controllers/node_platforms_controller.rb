class NodePlatformsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @node_platform if @node_platform.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @node_platforms.search(params[:q])
    @node_platforms = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @node_platforms
  end

  def show
    @details = @node_platform.details
    respond_with @node_platform
  end

  def new
    respond_with @node_platform
  end

  def create
    @node_platform = NodePlatform.create(node_platform_params.merge({ account_id: @current_account.id }))
    respond_with @node_platform
  end

  def update
    @node_platform.update_attributes(node_platform_params)
    respond_with @node_platform
  end

  def destroy
    @node_platform.destroy
    respond_with @node_platform
  end

  private

  def load_objects
    @available_build_scripts = NodeScript.accessible_by(@current_ability, :use).build_variety
    @available_init_scripts = NodeScript.accessible_by(@current_ability, :use).init_variety
    @available_utility_scripts = NodeScript.accessible_by(@current_ability, :use).utility_variety
    @available_node_architectures = NodeArchitecture.accessible_by(@current_ability, :use)
  end

  def node_platform_params
    permitted_params  = [:description,
                         :details,
                         :enabled,
                         :build_script_id,
                         :init_script_id,
                         :sync_script_id,
                         :name,
                         :node_architecture_id]
    permitted_params += [:public] if can?(:manage, NodePlatform)
    params.require(:node_platform).permit(*permitted_params)
  end
end
