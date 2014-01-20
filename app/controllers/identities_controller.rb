class IdentitiesController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    user_info = auth_hash['info']

    identity_info = {
      :provider => params[:provider],
      :provider_id => auth_hash['uid']
    }

    identity = Identity.find_by(identity_info)

    if identity.nil?
      identity = Identity.create!(identity_info.merge({
        :user => current_user,
        :name => user_info['nickname'] || user_info['name'],
        :email => user_info['email']
      }))
    end

    login_user(identity.user) if !logged_in?
    alert("Welcome, #{identity.user.name}!")

    redirect_to(root_path)
  end
end
