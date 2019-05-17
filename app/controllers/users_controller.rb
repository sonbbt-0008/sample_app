class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(create new)
  before_action :load_user, except: %i(index create new)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @users = User.paginate page: params[:page],
      per_page: Settings.index_per_page
  end

  def show
    @microposts = @user.microposts.descending.paginate(page: params[:page],
      per_page: Settings.index_per_page)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = t "check_email_announce"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "update_successful"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    flash[:success] = @user.destroy ? t("user_deleted") : t("delete_failed")
    redirect_to users_url
  end

  def following
    @title = t "following"
    @users = @user.following.paginate(page: params[:page],
      per_page: Settings.index_per_page)
    render :show_follow
  end

  def followers
    @title = t "followers"
    @users = @user.followers.paginate(page: params[:page],
      per_page: Settings.index_per_page)
    render :show_follow
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end

  def correct_user
    redirect_to root_url unless current_user?(@user)
  end

  def load_user
    return @user if @user = User.find_by(id: params[:id])
    flash.now[:danger] = t "user_not_found"
    redirect_to root_url
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
