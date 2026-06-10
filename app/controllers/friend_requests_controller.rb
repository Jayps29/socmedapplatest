class FriendRequestsController < ApplicationController
    before_action :authenticate_user!

    def create
      receiver = User.find(params[:receiver_id])

      return redirect_back(
        fallback_location: root_path
      ) if current_user.friends_with?(receiver)

      friend_request = current_user.sent_friend_requests.create!(
        receiver: receiver
      )

      FriendRequestNotifier.with(
        sender: current_user,
        friend_request_id: friend_request.id
      ).deliver(receiver)

      receiver.broadcast_notification(
      "#{current_user.username} sent you a friend request",
      "friend_request",
      profile_path(current_user),
      friend_request.id
      )

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

        request.sender.broadcast_notification(
          "#{current_user.username} accepted your friend request",
          "friend_accepted",
          profile_path(current_user)
        )

        request.destroy

        respond_to do |format|
          format.html do
            redirect_back fallback_location: root_path
          end

          format.turbo_stream { head :ok }
        end
      end

      def destroy
        request = FriendRequest.find(params[:id])

        if request.sender == current_user ||
           request.receiver == current_user

          request.destroy
        end

        respond_to do |format|
          format.html do
            redirect_back fallback_location: root_path
          end

          format.turbo_stream { head :ok }
        end
      end
end
