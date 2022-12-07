class Api::V1::SessionsController < Devise::SessionsController
  before_action :load_user, only: :create
  before_action :valid_token, only: :destroy
  skip_before_action :verify_signed_out_user, only: :destroy

  def create
    if @user.valid_password?(sign_in_params[:password])
      sign_in 'user', @user
      json_response 'signed in successfully', true, { user: @user }, :ok
    else
      json_response 'unauthorized', false, {}, :unauthorized
    end
  end

  def destroy
    sign_out @user
    @user.generate_new_authentication_token
    json_response 'log out successfully', true, {}, :ok
  end

  private

  def sign_in_params
    params.require(:sign_in).permit(:email, :password)
  end

  def load_user
    @user = User.find_for_database_authentication(email: sign_in_params[:email])
    return @user if @user

    json_response 'cannot get user', false, {}, :internal_server_error
  end

  def valid_token
    @user = User.find_by authentication_token: request.headers['AUTH-TOKEN']
    @user || json_response('invalid token', false, {}, :internal_server_error)
  end
end
