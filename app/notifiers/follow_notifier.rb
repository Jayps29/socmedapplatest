class FollowNotifier < ApplicationNotifier
  notification_methods do
    def message
      "#{params[:follower].username} started following you"
    end

    def url
      profile_path(params[:follower])
    end
  end
end
