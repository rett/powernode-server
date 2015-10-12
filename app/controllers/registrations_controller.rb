class RegistrationsController < Devise::RegistrationsController
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
                        :plan_id]
    params.require(:user).permit(*permitted_params)
  end
end

