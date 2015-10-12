class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  rescue_from ActionController::InvalidAuthenticityToken,
              ActiveRecord::RecordNotFound,
              CanCan::AccessDenied, with: :deny_access

  before_action :set_session
  before_action :set_credentials
  before_action :set_header
  before_action :add_breadcrumbs
  before_action :set_locale
  before_action :collect_billing_info

  protect_from_forgery with: :exception

  protected

  def collect_billing_info
    redirect_to billing_account_path(@current_account) if user_signed_in? && @current_account.requires_billing_info?
  end

  private

  def deny_access(exception)
    flash[:alert] ||= I18n.t('flash.actions.alert_access_denied')
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
    @current_ability = Ability.new(user: @current_user, account: @current_account, admin_view: session[:admin_view])
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
    unless action == 'index'
      resource_name = resource_name.singularize
    end
    if I18n.exists?("#{controller_name}.header.#{action}")
      @title = I18n.t("#{controller_name}.header.#{action}", resource_name: resource_name)
    else
      @title = I18n.t("header.actions.#{action}", resource_name: resource_name)
    end
  end

  def set_locale
    I18n.locale ||= current_user.locale if current_user.try(:locale)
  end

  def set_session
    if user_signed_in?
      session[:admin_console] = params[:admin_console].to_bool if params[:admin_console]
      session[:admin_view] = params[:admin_view].to_bool if params[:admin_view]
      session[:fixed_view] = params[:fixed_view].to_bool if params[:fixed_view]
    else
      session[:invitation_id] = params[:invitation_id] if params[:invitation_id]
      session[:plan_id] = params[:plan_id] if params[:plan_id]
    end
  end
end
