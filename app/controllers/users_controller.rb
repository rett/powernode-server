class UsersController < ApplicationController
  load_resource except: [:create]
  authorize_resource

  before_action { add_breadcrumb @user if @user.try(:persisted?) }
  before_action :check_user_limit, only: [:create, :new]
  before_action :load_roles, only: [:create, :new, :edit, :show, :update]
  before_action :filter_roles, only: [:create, :update]

  respond_to :html

  def index
    @search = @users.search(params[:q])
    @users = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @users
  end

  def show
    respond_with @user
  end

  def new
    respond_with @user
  end

  def create
    @user = User.create(user_params.merge({ account_id: @current_account.id }))
    respond_with @user
  end

  def update
    if user_params[:password].blank?
      @user.update_without_password(user_params)
    else
      @user.update_attributes(user_params)
      sign_in(@user, :bypass => true) if @user == @current_user
    end
    respond_with @user
  end

  def destroy
    if @user == @current_user
      redirect_to users_path, alert: I18n.t('flash.users.destroy.alert_current_user', resource_name: @user.name)
    else
      @user.destroy
      respond_with @user
    end
  end

  private

  def check_user_limit
    if @current_account.reached_user_limit?
      redirect_to users_path, alert: I18n.t('flash.users.create.alert_limit_reached')
    end
  end

  def filter_roles
    if params[:user].try(:[], :roles)
      params[:user][:roles].delete_if { |role| !current_user.has_role?(role) } unless can?(:manage, User)
    end
  end

  def load_roles
    @available_roles = can?(:manage, User) ? User::ROLES : current_user.roles.map(&:to_s)
    @disabled_roles = @available_roles if @user == current_user
  end

  def user_params
    permitted_params  = [:email,
                         :locale,
                         :login,
                         :name,
                         :password,
                         :password_confirmation,
                         :remember_me]
    permitted_params += [{ roles: [] }] unless @user == current_user
    params.require(:user).permit(*permitted_params)
  end
end
