class PostsController < ApplicationController
    before_action :authenticate_user!

    def create
      @post = current_user.posts.build(post_params)

      if @post.save
        redirect_back fallback_location: root_path
      else
        redirect_back fallback_location: root_path,
                      alert: "Unable to create post"
      end
    end

    def show
      @post = Post.find(params[:id])
    end

    def edit
      @post = current_user.posts.find(params[:id])
    end

    def update
      @post = current_user.posts.find(params[:id])

      if @post.update(post_params)
        redirect_back fallback_location: root_path,
                      notice: "Post updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post = current_user.posts.find(params[:id])

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
