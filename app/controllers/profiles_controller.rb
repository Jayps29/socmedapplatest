class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])

    authorize! :read, @user

    @pagy, @posts = pagy(
      :offset,
      @user.posts
           .includes(
             {
               user: {
                 avatar_attachment: :blob
               }
             },
             :likes,
             images_attachments: :blob,
             comments: {
               user: {
                 avatar_attachment: :blob
               }
             }
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
