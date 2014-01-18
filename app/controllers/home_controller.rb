class HomeController < ApplicationController
  def index
    @user = current_user || User.new
    render(:action => logged_in? && 'app' || 'guest')
  end

  def login
    @user = User.new(user_params)

    existing_user = User.find_by(:user_name => @user.user_name)

    if existing_user.nil?
      alert('No user by that name exists. Did you make a typo?')
      return render(:action => 'guest')
    end

    if !existing_user.authenticate(@user.password)
      alert("That isn't the right password! Are you sure you're #{@user.user_name}?")
      return render(:action => 'guest')
    end

    login_user(existing_user)
    alert("Welcome back, #{existing_user.name}!")

    redirect_to(root_path)
  end

  def login_with_oauth
    auth_hash = request.env['omniauth.auth']
    user_info = auth_hash['info']

    identity_info = {
      :provider => params[:provider],
      :provider_id => auth_hash['uid']
    }

    identity = Identity.find_by(identity_info)

    if identity.nil?
      identity = Identity.create!(identity_info.merge({
        :name => user_info['nickname'] || user_info['name'],
        :email => user_info['email']
      }))
    end

    login_user(identity.user)
    alert("Welcome, #{identity.user.name}!")

    redirect_to(root_path)
  end

  def register
    @user = User.new(user_params)

    if @user.save
      login_user(@user)
      alert('Thank you for registering!')
      return redirect_to(root_path)
    end

    alert('There was a problem creating your account.')
    render(:action => 'guest')
  end

  def logout
    logout_user
    alert('You have successfully logged out.')
    redirect_to(root_path)
  end

  private

  def user_params
    params.require(:user).permit(
      :user_name,
      :real_name,
      :password,
      :password_confirmation
    )
  end
end
