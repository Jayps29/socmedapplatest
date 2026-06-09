class FriendAcceptedNotifier < ApplicationNotifier
  notification_methods do
    def message
      "#{params[:user].username} accepted your friend request"
    end

    def url
      profile_path(params[:user])
    end
  end
end
