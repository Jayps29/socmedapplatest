class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @posts = pagy(
      :offset,
      Post.feed_for(current_user)
          .includes(
            :user,
            :comments,
            :likes,
            images_attachments: :blob
          )
          .order(created_at: :desc),
      limit: 10
    )

    @post = Post.new
  end
end
