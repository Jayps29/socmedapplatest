class LikesController < ApplicationController
    before_action :authenticate_user!

    def create
      post = Post.find(params[:post_id])

      like = current_user.likes.create(post: post)

      unless post.user == current_user
        LikeNotificationJob.perform_later(
          post.id,
          current_user.id
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
