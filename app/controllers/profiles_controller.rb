class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])

    @pagy, @posts = pagy(
      :offset,
      @user.posts
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

    @friends = @user.friends
    @followers = @user.followers
    @following = @user.following
  end
end
