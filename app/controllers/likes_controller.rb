class LikesController < ApplicationController
    before_action :authenticate_user!

    def create
      post = Post.find(params[:post_id])

      like = current_user.likes.create(post: post)

      unless post.user == current_user
        LikeNotifier.with(
        user: current_user,
        post: post
      ).deliver(post.user)

      post.user.broadcast_notification(
      "#{current_user.username} liked your post",
      "like",
      post_path(post)
      )
      end

      redirect_back fallback_location: root_path
    end

    def destroy
      like = current_user.likes.find(params[:id])

      like.destroy

      redirect_back fallback_location: root_path
    end
end
