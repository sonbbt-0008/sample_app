class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user&.authenticated?(:activation, params[:id]) && !user.activated?
      user_authenticate user
    else
      flash[:danger] = t "invalid_activation_link"
      redirect_to root_url
    end
  end

  private

  def user_authenticate user
    user.activate
    log_in user
    flash[:success] = t "account_activated"
    redirect_to user
  end
end
