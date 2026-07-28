class PostsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource except: %i[create comments]

  def create
    @post = current_user.posts.build(post_params)
    authorize! :create, @post

    if @post.save
      redirect_back fallback_location: root_path
    else
      redirect_back fallback_location: root_path,
                    alert: "Unable to create post"
    end
  end

  def show
  end

  def comments
    @post = Post.find(params[:id])
    authorize! :read, @post

    limit = params[:limit].present? ? params[:limit].to_i : 10

    @comments = @post.comments
                     .includes(
                       user: {
                         avatar_attachment: :blob
                       }
                     )
                     .order(created_at: :desc)
                     .limit(limit)

    @limit = limit
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_back fallback_location: root_path,
                    notice: "Post updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy

    respond_to do |format|
      format.html do
        redirect_back fallback_location: root_path
      end

      format.turbo_stream
    end
  end

  private

  def post_params
    params.require(:post)
          .permit(:content, images: [])
  end
end
