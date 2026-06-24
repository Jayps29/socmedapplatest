class FriendAcceptedNotificationJob < ApplicationJob
  queue_as :default

  def perform(sender_id, accepter_id)
    sender = User.find_by(id: sender_id)
    accepter = User.find_by(id: accepter_id)

    return unless sender && accepter

    FriendAcceptedNotifier.with(
      user: accepter
    ).deliver(sender)

    sender.broadcast_notification(
      "#{accepter.username} accepted your friend request",
      "friend_accepted",
      Rails.application.routes.url_helpers.profile_path(accepter)
    )
  end
end
