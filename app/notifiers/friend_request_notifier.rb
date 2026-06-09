class FriendRequestNotifier < ApplicationNotifier
  notification_methods do
    def message
      "#{params[:sender].username} sent you a friend request"
    end

    def url
      Rails.application.routes.url_helpers.profile_path(
        params[:sender]
      )
    end
  end
end
