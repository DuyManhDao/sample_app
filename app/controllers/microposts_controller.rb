class MicropostsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach params.dig(:micropost, :image)
    if @micropost.save
      handle_successful_save
    else
      handle_failed_save
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t("micropost.deleted")
    else
      flash[:danger] = t("micropost.delete_fail")
    end
    redirect_to request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit :content, :image
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t("micropost.invalid")
    redirect_to request.referer || root_url
  end

  def handle_successful_save
    flash[:success] = t "micropost.created"
    redirect_to root_url
  end

  def handle_failed_save
    @pagy, @feed_items = pagy(current_user.feed.newest, items: Settings.page_10)
    render "static_pages/home", status: :unprocessable_entity
  end
end
