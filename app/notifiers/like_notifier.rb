class LikeNotifier < ApplicationNotifier
  notification_methods do
    def message
      "#{params[:user].username} liked your post"
    end

    def url
      post_path(params[:post])
    end
  end
end
