class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_not_following, only: :create
  before_action :load_following, only: :destroy

  def create
    current_user.follow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    current_user.unfollow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  private

  def load_not_following
    return @user if @user = User.find_by(id: params[:followed_id])
    flash[:danger] = t "user_not_found"
    redirect_to root_url
  end

  def load_following
    return @user if @user = Relationship.find_by(id: params[:id]).followed
    flash[:danger] = t "user_not_found"
    redirect_to root_url
  end
end
