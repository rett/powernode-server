class NodeModuleCategoriesController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @node_module_category if @node_module_category.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @node_module_categories.search(params[:q])
    @node_module_categories = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @node_module_categories
  end

  def show
    @details = @node_module_category.details
    respond_with @node_module_category
  end

  def new
    respond_with @node_module_category
  end

  def create
    @node_module_category = NodeModuleCategory.create(node_module_category_params.merge({ account_id: @current_account.id }))
    respond_with @node_module_category
  end

  def update
    @node_module_category.update_attributes(node_module_category_params)
    respond_with @node_module_category
  end

  def destroy
    @node_module_category.destroy
    respond_with @node_module_category
  end

  private

  def load_objects
    @available_node_module_categories = NodeModuleCategory.accessible_by(@current_ability, :use)
  end

  def node_module_category_params
    permitted_params = [:config_category_id,
                        :instance_category_id,
                        :description,
                        :details,
                        :enabled,
                        :name,
                        :priority,
                        :reboot_required,
                        :variety]
    permitted_params += [:public] if can?(:manage, NodeModuleCategory)
    params.require(:node_module_category).permit(*permitted_params)
  end
end
