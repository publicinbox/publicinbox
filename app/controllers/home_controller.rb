class HomeController < ApplicationController
  def index
    @user = current_user || User.new
    return redirect_to('/ui/mailbox') if logged_in?
    render
  end

  def app
    render(:layout => false)
  end

  def login
    if request.post?
      @user = User.new(user_params)

      existing_user = User.find_by(:user_name => @user.user_name)

      if existing_user.nil?
        alert('No user by that name exists. Did you make a typo?', 'error')
        return render(:action => 'login')
      end

      if !existing_user.authenticate(@user.password)
        alert("That isn't the right password! Are you sure you're #{@user.user_name}?", 'error')
        return render(:action => 'login')
      end

      login_user(existing_user)
      alert("Welcome back, #{existing_user.name}!")

      redirect_to('/ui/mailbox')

    else
      @user = User.new
    end
  end

  def register
    if request.post?
      @user = User.new(user_params)

      # I know this ugly validation shouldn't really be *here*; but for now this
      # is the simplest solution to the problem that a user account should
      # require a password *sometimes* but not *always* (i.e., when creating an
      # account through PublicInbox it should be required, but when logging in
      # through an external provider like Google it shouldn't).
      #
      # Really it would probably be better to have a PublicInboxIdentity model
      # and put the password there. But you know how it is with tech debt.
      error_message = nil
      if @user.password.blank?
        error_message = 'You forgot to specify a password!'
      elsif user_params[:password_confirmation] != @user.password
        error_message = "Your password confirmation didn't match."
      end

      if error_message.nil? && @user.save
        login_user(@user)
        alert('Thank you for registering!')
        return redirect_to(root_path)
      end

      alert(error_message || validation_error_message(@user) || 'There was a problem creating your account.', 'error')

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
