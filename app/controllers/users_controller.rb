class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(edit update destroy)
  before_action :find_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy User.newest_first, items: Settings.page_10
  end

  def show
    @page, @microposts = pagy @user.microposts.newest, items: Settings.page_10
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t("user.activate")

      redirect_to root_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t("user.updated")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t("user.deleted")
    else
      flash[:danger] = t("user.delete_fail")
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
                                 :password_confirmation
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t("user.not_found")
    redirect_to root_path
  end

  # def logged_in_user
  #   return if logged_in?

  #   store_location
  #   flash[:danger] = t "user.logged_in?"
  #   redirect_to login_url
  # end

  def correct_user
    return if current_user?(@user)

    flash[:error] = t("user.current_user?")
    redirect_to root_url
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
