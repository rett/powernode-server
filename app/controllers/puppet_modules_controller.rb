class PuppetModulesController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @puppet_module if @puppet_module.try(:persisted?) }
  respond_to :html

  def index
    @search = @puppet_modules.search(params[:q])
    @puppet_modules = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @puppet_modules
  end

  def show
    @details = @puppet_module.details
    respond_with @puppet_module
  end

  def new
    respond_with @puppet_module
  end

  def create
    @puppet_module = PuppetModule.create(puppet_module_params.merge({ account_id: @current_account.id }))
    respond_with @puppet_module
  end

  def update
    @puppet_module.update_attributes(puppet_module_params)
    respond_with @puppet_module
  end

  def destroy
    @puppet_module.destroy
    respond_with @puppet_module
  end

  private

  def puppet_module_params
    permitted_params  = [{ puppet_resources_attributes: [:id,
                                                         :data,
                                                         :description,
                                                         :details,
                                                         :enabled,
                                                         :name,
                                                         :path,
                                                         :_destroy] },
                         :data,
                         :description,
                         :details,
                         :enabled,
                         :name]
    permitted_params += [:public] if can?(:manage, PuppetModule)
    params.require(:puppet_module).permit(*permitted_params)
  end
end
