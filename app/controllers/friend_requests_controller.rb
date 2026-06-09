class FriendRequestsController < ApplicationController
    before_action :authenticate_user!

    def create
        receiver = User.find(params[:receiver_id])

        return redirect_back(
          fallback_location: root_path
        ) if current_user.friends_with?(receiver)

        current_user.sent_friend_requests.create!(
          receiver: receiver
        )

        FriendRequestNotifier.with(
  sender: current_user
).deliver(receiver)



receiver.broadcast_notification_badge

redirect_back fallback_location: root_path
      end

      def update
        request = current_user.received_friend_requests.find(params[:id])

        Friendship.create!(
          user: request.sender,
          friend: request.receiver
        )

        Friendship.create!(
          user: request.receiver,
          friend: request.sender
        )

        FriendAcceptedNotifier.with(
  user: current_user
).deliver(request.sender)

request.sender.broadcast_notification_badge

        request.destroy

        redirect_back fallback_location: root_path
      end

    def destroy
      request = FriendRequest.find(params[:id])

      if request.sender == current_user ||
         request.receiver == current_user

        request.destroy
      end

      redirect_back fallback_location: root_path
    end
end
