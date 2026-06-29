class FriendRequestNotificationJob < ApplicationJob
  queue_as :default

  def perform(friend_request_id)
    friend_request = FriendRequest.find(friend_request_id)

    receiver = friend_request.receiver
    sender = friend_request.sender

    FriendRequestNotifier.with(
      sender: sender,
      friend_request_id: friend_request.id
    ).deliver(receiver)

    receiver.broadcast_notification(
      "#{sender.username} sent you a friend request",
      "friend_request",
      Rails.application.routes.url_helpers.profile_path(sender),
      friend_request.id
    )
  end
end
