class CommentsController < ApplicationController
    before_action :authenticate_user!

    def create
      @post = Post.find(params[:post_id])

      @comment = @post.comments.build(comment_params)
      @comment.user = current_user

      if @comment.save

        unless @post.user == current_user
          CommentNotifier.with(
            user: current_user,
            post: @post,
            comment: @comment
          ).deliver(@post.user)
          @post.user.broadcast_notification_badge
        end

        redirect_back fallback_location: root_path
      else
        redirect_back fallback_location: root_path,
                      alert: "Comment could not be created."
      end
    end

    def edit
      @comment = current_user.comments.find(params[:id])
    end

    def update
      @comment = current_user.comments.find(params[:id])

      if @comment.update(comment_params)
        redirect_back fallback_location: root_path,
                      notice: "Comment updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @comment = Comment.find(params[:id])

      unless @comment.user == current_user ||
             @comment.post.user == current_user

        redirect_back fallback_location: root_path,
                      alert: "Not authorized."
        return
      end

      @comment.destroy

      respond_to do |format|
        format.html do
          redirect_back fallback_location: root_path
        end

        format.turbo_stream
      end
    end

    private

    def comment_params
      params.require(:comment)
            .permit(:content)
    end
end
