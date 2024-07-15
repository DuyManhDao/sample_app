class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = "User not found!"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      reset_session
      log_in @user
      flash[:success] = t "welcome_to_the_sample_app!"
      redirect_to @user, status: :see_other
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
                                 :password_confirmation
  end
end
