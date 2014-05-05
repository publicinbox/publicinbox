class ProfileController < ApplicationController
  include ApiHelper

  def show
    render(:json => render_user(current_user))
  end

  private

  def render_user(user)
    {
      :id => user.id,
      :user_name => user.user_name,
      :real_name => user.real_name,
      :email => user.email,
      :external_email => user.external_email,
      :profile_image => profile_image(user.external_email || user.email, :size => 100),
      :bio => markdown(user.bio),
      :created_at => time_ago_in_words(user.created_at)
    }
  end
end
