class Api::V1::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_params_exist, only: :create

  def create
    user = User.new user_params
    if user.save
      json_response 'singed up successfully', true, { user: }, :ok
    else
      json_response 'something wrong', false, {}, :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def ensure_params_exist
    return if params[:user].present?

    json_response 'missing params', false, {}, :bad_request
  end
end
