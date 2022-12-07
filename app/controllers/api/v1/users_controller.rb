class Api::V1::UsersController < ApplicationController
  def facebook
    if params[:facebook_access_token]
      grahp = Koala::Facebook::API.new params[:facebook_access_token]
      user_data = grahp.get_object('me?fields=id,name,email,picture')
      puts user_data

      user = User.find_by email: user_data['email']
      if user
        user.generate_new_authentication_token
        json_response 'user information', true, { user: }, :ok
      else
        user = User.new(
          email: user_data['email'],
          uid: user_data['id'],
          provide: 'facebook',
          image: user_data['picture']['data']['url'],
          password: Devise.friendly_token[0, 20]
        )

        user.authentication_token = User.generate_unique_secure_token

        if user.save
          json_response 'login Facebook successfully', true, { user: }, :ok
        else
          json_response user.errors, false, {}, :unprocessable_entity
        end
      end
    else
      json_response 'missing Facebook access token', false, {}, :unprocessable_entity
    end
  end
end
