class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      login_redirect user
    else
      flash.now[:danger] = I18n.t "invalid_user"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
  def login_redirect user
    if user.activated?
      log_in user
      params[:session][:remember_me] == Settings.checked ? remember(user) : forget(user)
      redirect_back_or user
    else
      flash[:danger] = t("account_inactivated") << t("check_email_announce")
      redirect_to root_url
    end
  end
end
