class RegistrationsController < Devise::RegistrationsController
  def create
    resource = @user = build_resource(sign_up_params)
    @credit_card = CreditCard.new(params)
    @plan = Plan.available.find_by(id: params[:user].present? ? params[:user][:plan_id] : params[:plan_id])
    if resource.save && params[:credit_card].present?
      resource.account.stripe_card = params[:credit_card][:stripe_card]
      resource.account.stripe_card_exp_month = params[:credit_card][:exp_month]
      resource.account.stripe_card_exp_year = params[:credit_card][:exp_year]
      resource.account.stripe_card_last4 = params[:credit_card][:stripe_card_last4]
      resource.account.stripe_token = params[:credit_card][:stripe_token]
      resource.account.save
    end
    if resource.persisted?
      redirect_to(page_path('thanks'))
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def new
    if params[:plan_id]
      @credit_card = CreditCard.new(params)
      @plan = Plan.available.find_by(id: params[:user].present? ? params[:user][:plan_id] : params[:plan_id])
      super
    else
      redirect_to(auth_plans_path)
    end
  end

  def plans
    @plans = Plan.available.featured
  end

  private

  def sign_up_params
    permitted_params = [:name,
                        :email,
                        :invitation_id,
                        :locale,
                        :password,
                        :password_confirmation,
                        :plan_id,
                        :stripe_card,
                        :stripe_card_cvc,
                        :stripe_card_exp_month,
                        :stripe_card_exp_year,
                        :stripe_card_last4,
                        :stripe_card_number,
                        :stripe_token]
    params.require(:user).permit(*permitted_params)
  end
end

