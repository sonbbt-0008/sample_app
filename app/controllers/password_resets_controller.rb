class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration, only: %i(edit
    update)

  def new; end

  def edit; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "password_reset_email_sent"
      redirect_to root_url
    else
      flash.now[:danger] = t "invalid_user"
      render :new
    end
  end

  def update
    if params[:user][:password].blank?
      @user.errors.add :password, t("password_empty")
      render :edit
    elsif @user.update_attributes user_params
      log_in @user
      flash[:success] = t "password_reset"
      redirect_to @user
    else
      flash[:danger] = t "something_wrong"
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def load_user
    return @user if @user = User.find_by(email: params[:email])
    flash.now[:danger] = t "user_not_found"
    redirect_to root_url
  end

  def valid_user
    return if @user&.activated? && @user.authenticated?(:reset, params[:id])
    flash[:danger] = t "invalid_user"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "password_expired"
    redirect_to new_password_reset_url
  end
end
