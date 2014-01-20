class UsersController < ApplicationController
  def update
    user = User.find(params[:id])

    if user != current_user
      alert("You can't edit somebody else's profile!")
    elsif user.update_attributes(user_params)
      alert('Profile successfully updated.')
    else
      alert('There was a problem trying to save your profile.')
    end

    redirect_to(root_path)
  end

  private

  def user_params
    params.require(:user).permit(:user_name, :real_name, :bio)
  end
end
