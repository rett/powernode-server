class PagesController < ApplicationController
  load_resource except: [:create, :show]
  authorize_resource

  before_action { add_breadcrumb @page if @page.try(:persisted?) }

  respond_to :html

  def index
    @search = @pages.search(params[:q])
    @pages = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @pages
  end

  def show
    if params[:id] =~ /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/
      @page = Page.accessible_by(@current_ability, :show).find_by(id: params[:id])
    else
      @page = Page.accessible_by(@current_ability, :show).find_by(name: params[:id])
    end
    @page ||= Page.accessible_by(@current_ability, :show).find_by(name: 'welcome')
    @page ||= Page.new
    @details = @page.content
    @title = @page.title if @page.persisted?
    respond_with @page
  end

  def new
    @page.name = params[:name]
    respond_with @page
  end

  def create
    @page = Page.create(page_params.merge({ account_id: @current_account.id }))
    respond_with @page
  end

  def update
    @page.update_attributes(page_params)
    respond_with @page
  end

  def destroy
    @page.destroy
    respond_with @page
  end

  private

  def page_params
    permitted_params  = [:content,
                         :enabled,
                         :name,
                         :title]
    permitted_params += [:public] if can?(:manage, Page)
    params.require(:page).permit(*permitted_params)
  end
end
