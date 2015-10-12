class InvitationsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @invitation if @invitation.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def index
    @search = @invitations.search(params[:q])
    @invitations = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @invitations
  end

  def show
    @details = @invitation.details
    respond_with @invitation
  end

  def new
    respond_with @invitation
  end

  def create
    @invitation = Invitation.create(invitation_params.merge({ account_id: @current_account.id }))
    respond_with @invitation
  end

  def update
    @invitation.update_attributes(invitation_params)
    respond_with @invitation
  end

  def destroy
    @invitation.destroy
    respond_with @invitation
  end

  private

  def invitation_params
    permitted_params = [:recipient]
    params.require(:invitation).permit(*permitted_params)
  end

  def load_objects
    @available_plans = Plan.accessible_by(@current_ability, :use)
  end
end
