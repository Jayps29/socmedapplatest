class CommentsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource except: [ :create ]

  def create
    @post = Post.find(params[:post_id])

    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    authorize! :create, @comment

    if @comment.save
      unless @post.user == current_user
        CommentNotificationJob.perform_later(
          @post.id,
          @comment.id,
          current_user.id
        )
      end

      redirect_back fallback_location: root_path
    else
      redirect_back fallback_location: root_path,
                    alert: "Comment could not be created."
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_back fallback_location: root_path,
                    notice: "Comment updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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
