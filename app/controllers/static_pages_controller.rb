class StaticPagesController < ApplicationController
  def home
    return unless logged_in?
    @user = current_user
    @micropost = current_user.microposts.build
    @feed_items = current_user.feed.descending.paginate page: params[:page],
      per_page: Settings.index_per_page
  end

  def help; end

  def about; end

  def contact; end
end
