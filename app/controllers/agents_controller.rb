class AgentsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @agent if @agent.try(:persisted?) }

  respond_to :html

  def index
    @search = @agents.search(params[:q])
    @agents = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @agents
  end

  def show
    @details = @agent.details
    respond_with @agent
  end

  def new
    respond_with @agent
  end

  def edit
    respond_with @agent
  end

  def create
    @agent = Agent.create(agent_params.merge({ account_id: @current_account.id }))
    respond_with @agent
  end

  def update
    @agent.update_attributes(agent_params)
    respond_with @agent
  end

  def destroy
    @agent.destroy
    respond_with @agent
  end

  private

  def agent_params
    permitted_params = [{ roles: [] },
                        :description,
                        :details,
                        :enabled,
                        :name,
                        :proxy_url,
                        :key,
                        :key_confirmation]
    permitted_params += [:public, :primary] if can?(:manage, Agent)
    params.require(:agent).permit(*permitted_params)
  end
end
