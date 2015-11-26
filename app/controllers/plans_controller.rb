class PlansController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @plan if @plan.try(:persisted?) }

  respond_to :html

  def index
    @search = @plans.search(params[:q])
    @plans = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @plans
  end

  def show
    respond_with @plan
  end

  def new
    respond_with @plan
  end

  def create
    @plan = Plan.create(plan_params.merge({ account_id: @current_account.id }))
    respond_with @plan
  end

  def update
    @plan.update_attributes(plan_params)
    respond_with @plan
  end

  def destroy
    @plan.destroy
    respond_with @plan
  end

  private

  def plan_params
    permitted_params  = [{ default_roles: [],
                           pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy] },
                         :amount,
                         :description,
                         :instance_limit,
                         :interval,
                         :interval_count,
                         :name,
                         :node_limit,
                         :statement_descriptor,
                         :trial_period_days,
                         :user_limit]
    permitted_params += [:featured, :public] if can?(:manage, Plan)
    params.require(:plan).permit(*permitted_params)
  end
end
