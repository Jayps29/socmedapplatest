class CommentNotifier < ApplicationNotifier
  notification_methods do
    def message
      "#{params[:user].username} commented on your post"
    end

    def url
      post_path(params[:post])
    end
  end
end
