class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  rescue_from ActionController::InvalidAuthenticityToken,
              ActiveRecord::RecordNotFound,
              CanCan::AccessDenied, with: :deny_access

  before_action :set_credentials
  before_action :set_preferences, if: :user_signed_in?
  before_action :set_signup, unless: :user_signed_in?
  before_action :set_header, if: :user_signed_in?
  before_action :add_breadcrumbs
  before_action :set_locale
  before_action :collect_billing_info, if: :user_signed_in?

  protect_from_forgery with: :exception

  private

  def collect_billing_info
    redirect_to billing_account_path(@current_account) if @current_account.requires_billing_info?
  end

  def deny_access(exception)
    flash['danger'] ||= I18n.t('flash.actions.danger_access_denied')
    logger.error %Q[ACCESS VIOLATION! IP: "#{request.ip}", User: "#{current_user.try(:email)}", Path: "#{request.fullpath}", Message: "#{exception.message}"]
    if request.xhr?
      render :js => %Q[window.location.replace("#{root_url}")]
    else
      redirect_to root_path
    end
  end

  def add_breadcrumbs
    unless self.class.ancestors.include?(DeviseController) || (controller_name == 'pages' && !can?(:update, @page))
      add_breadcrumb I18n.t('actions.home'), :root_path
      add_breadcrumb controller_name.titleize, try("#{controller_name}_path")
    end
  end

  def set_credentials
    @current_user = current_user
    @current_account = user_signed_in? ? (Account.accessible_by(Ability.new(user: @current_user)).find_by(id: session[:account_id]) || @current_user.account) : Account.new
    @current_ability = Ability.new(user: @current_user, account: @current_account, admin_view: user_signed_in? ? @current_user.preferences['admin_view'] : false)
  end

  def set_header
    case params[:action]
    when 'update'
      action = 'edit'
    when 'create'
      action = 'new'
    else
      action = params[:action]
    end
    resource_name = controller_name.titleize
    resource_name = resource_name.singularize unless action == 'index'
    if I18n.exists?("#{controller_name}.header.#{action}")
      @title = I18n.t("#{controller_name}.header.#{action}", resource_name: resource_name)
    else
      @title = I18n.t("header.actions.#{action}", resource_name: resource_name)
    end
  end

  def set_locale
    I18n.locale = @current_user.locale if @current_user.try(:locale)
  end

  def set_preferences
    @preferences = @current_user.preferences
    @preferences['admin_console'] = params[:admin_console].to_bool if params[:admin_console]
    @preferences['admin_view'] = params[:admin_view].to_bool if params[:admin_view]
    @preferences['fixed_view'] = params[:fixed_view].to_bool if params[:fixed_view]
    if @current_user.preferences_changed? && @current_user.save
      @current_ability = Ability.new(user: @current_user, account: @current_account, admin_view: @current_user.preferences['admin_view'])
    end
  end

  def set_signup
    session[:invitation_id] = params[:invitation_id] if params[:invitation_id]
    session[:plan_id] = params[:plan_id] if params[:plan_id]
  end
end
