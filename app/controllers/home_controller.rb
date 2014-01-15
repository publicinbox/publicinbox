class HomeController < ApplicationController
  def index
    if logged_in?
      @user = current_user
      render(:action => 'app')
    else
      render(:action => 'guest_index')
    end
  end

  def login
    if request.post?
      @user = User.new(user_params)

      existing_user = User.find_by(:user_name => @user.user_name)

      if existing_user.nil?
        alert('No user by that name exists. Did you make a typo?')
        return
      end

      if !existing_user.authenticate(@user.password)
        alert("That isn't the right password! Are you sure you're #{@user.user_name}?")
        return
      end

      login_user(existing_user)
      alert("Welcome back, #{existing_user.name}!")

      redirect_to(root_path)

    else
      @user = User.new
    end
  end

  def register
    if request.post?
      @user = User.new(user_params)

      if @user.save
        login_user(@user)
        alert('Thank you for registering!')
        redirect_to(root_path)
      else
        alert('There was a problem creating your account.')
      end

    else
      @user = User.new
    end
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
