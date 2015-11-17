class AccountsController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @account if @account.try(:persisted?) }
  before_action :load_objects, except: [:index]
  skip_before_filter :collect_billing_info

  respond_to :html, :js

  def index
    @search = @accounts.search(params[:q])
    @accounts = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @accounts
  end

  def show
    respond_with @account
  end

  def edit
    respond_with @account
  end

  def update
    @account.update_attributes(account_params)
    respond_with @account
  end

  def destroy
    @account.destroy
    respond_with @account
  end

  def billing
    if request.post? && params[:credit_card]
      @credit_card = CreditCard.new(params[:credit_card])
      @account.stripe_card = params[:credit_card][:stripe_card]
      @account.stripe_card_exp_month = params[:credit_card][:exp_month]
      @account.stripe_card_exp_year = params[:credit_card][:exp_year]
      @account.stripe_card_last4 = params[:credit_card][:stripe_card_last4]
      @account.stripe_token = params[:credit_card][:stripe_token]
      if @account.save
        redirect_to account_path(@account), notice: I18n.t('flash.accounts.billing.success')
      else
        flash['danger'] = I18n.t('flash.accounts.billing.danger')
      end
    else
      @credit_card = CreditCard.new
    end
  end

  def cancel
    @page = Page.accessible_by(@current_ability, :show).find_by(name: 'cancel') || Page.new
    if request.post? && params[:confirm].present?
      sign_out(:user) if @account.destroy && @account == @current_account
      redirect_to page_path('canceled') and return
    elsif request.post?
      flash['danger'] = 'You must confirm you wish to cancel.'
    end
  end

  def delegation
    if request.post?
      if (user = User.find_by(email: params[:email])) && user != @current_user && user.account != @current_account && can?(:update, @account)
        if user.accounts.include?(@account)
          @delegation = AccountDelegation.find_by(account_id: @account.id, user_id: user.id)
          @delegation.expiration = params[:expiration]
        else
          @delegation = AccountDelegation.new(account_id: @account.id, user_id: user.id, expiration: params[:expiration])
        end
        flash['success'] = I18n.t('flash.accounts.delegation.add.success') if @delegation.save
      else
        flash['danger'] = I18n.t('flash.accounts.delegation.add.danger')
      end
    elsif request.delete?
      if (@delegation = @account.account_delegations.find_by(id: params[:delegation_id])) && can?(:update, @delegation.account) && @delegation.destroy
        flash['success'] = I18n.t('flash.accounts.delegation.remove.success')
      else
        flash['danger'] = I18n.t('flash.accounts.delegation.remove.danger')
      end
    end
    respond_with @account, locals: { delegation: @delegation }
  end

  def notice_delete_id
    if params[:notice_id] == 'all'
      @account.notices.destroy
    else
      @account.notices.where(id: params[:notice_id]).destroy
    end
  end

  def plan
    @plans = Plan.accessible_by(@current_ability, :use).order('amount asc')
    if request.post?
      @plan = Plan.find_by(id: params[:plan_id])
      @account.plan = @plan if @account.qualifies_for?(@plan)
      if @account.save
        redirect_to account_path(@account), notice: I18n.t('flash.accounts.plan.success')
      else
        flash['danger'] = I18n.t('flash.accounts.plan.danger')
      end
    end
  end

  def select
    @accounts = Account.accessible_by(@current_ability, :select)
    if (@account = @accounts.find_by(id: params[:id]))
      session[:account_id] = @account.id
      @current_account = @account
      flash['success'] = I18n.t('flash.accounts.select.success', account: @account.name)
    else
      flash['danger'] = I18n.t('flash.accounts.select.danger')
      raise CanCan::AccessDenied
    end
    respond_with @account do |format|
      format.html { redirect_to action: 'show' }
    end
  end

  private

  def load_objects
    @available_agents = Agent.accessible_by(@current_ability, :use)
  end

  def account_params
    permitted_params = [:name, :plan_id]
    permitted_params += [:agent_id] if can?(:manage, Account)
    params.require(:account).permit(*permitted_params)
  end
end
