class PlansController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @plan if @plan.try(:persisted?) }
  before_action :load_roles, only: [:create, :new, :edit, :update]

  respond_to :html

  def index
    @search = @plans.search(params[:q])
    @plans = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @plans
  end

  def show
    @details = @plan.details
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

  def load_roles
    @available_roles = User::ROLES
  end

  def plan_params
    permitted_params  = [{ default_roles: [] },
                         :amount,
                         :description,
                         :details,
                         :featured,
                         :instance_limit,
                         :interval,
                         :interval_count,
                         :name,
                         :node_limit,
                         :statement_descriptor,
                         :trial_period_days,
                         :user_limit]
    permitted_params += [:public] if can?(:manage, Plan)
    params.require(:plan).permit(*permitted_params)
  end
end
