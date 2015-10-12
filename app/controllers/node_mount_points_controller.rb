class NodeMountPointsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @node_mount_point if @node_mount_point.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @node_mount_points.search(params[:q])
    @node_mount_points = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @node_mount_points
  end

  def show
    @details = @node_mount_point.details
    respond_with @node_mount_point
  end

  def new
    respond_with @node_mount_point
  end

  def create
    @node_mount_point = NodeMountPoint.create(node_mount_point_params.merge({ account_id: @current_account.id }))
    respond_with @node_mount_point
  end

  def destroy
    @node_mount_point.destroy
    respond_with @node_mount_point
  end

  def update
    @node_mount_point.update_attributes(node_mount_point_params)
    respond_with @node_mount_point
  end

  private

  def load_objects
    @available_dependencies = NodeMountPoint.accessible_by(@current_ability, :use).select { |m| m != @node_mount_point }
    @available_node_modules = NodeModule.accessible_by(@current_ability, :use)
    @available_mount_scripts = NodeScript.accessible_by(@current_ability, :use).mount_variety
  end

  def node_mount_point_params
    permitted_params  = [:description,
                         :details,
                         :device,
                         :enabled,
                         :mount_script_id,
                         :node_module_id,
                         :node_mount_point_dependency_id,
                         :name,
                         :parameters,
                         :path]
    permitted_params += [:public] if can?(:manage, NodeMountPoint)
    params.require(:node_mount_point).permit(*permitted_params)
  end
end
