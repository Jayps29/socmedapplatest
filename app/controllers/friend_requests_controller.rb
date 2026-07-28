class FriendRequestsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource only: [ :destroy ]

  def create
    receiver = User.find(params[:receiver_id])

    return redirect_back(
      fallback_location: root_path
    ) if current_user.friends_with?(receiver)

    @friend_request = current_user.sent_friend_requests.build(
      receiver: receiver
    )

    authorize! :create, @friend_request

    @friend_request.save!

    FriendRequestNotificationJob.perform_later(
      @friend_request.id
    )

    redirect_back fallback_location: root_path
  end

  def update
    request = current_user.received_friend_requests.find(params[:id])

    authorize! :accept, request

    Friendship.create!(
      user: request.sender,
      friend: request.receiver
    )

    Friendship.create!(
      user: request.receiver,
      friend: request.sender
    )

    FriendAcceptedNotificationJob.perform_later(
      request.sender.id,
      current_user.id
    )

    request.destroy

    current_user.remove_friend_request_notification(request.id)

    current_user.broadcast_notification_badge
    current_user.broadcast_notification_dropdown

    respond_to do |format|
      format.html do
        redirect_back fallback_location: root_path
      end

      format.turbo_stream { head :ok }
    end
  end

  def destroy
    friend_request_id = @friend_request.id

    if @friend_request.sender == current_user
      receiver = @friend_request.receiver

      @friend_request.destroy

      receiver.remove_friend_request_notification(
        friend_request_id
      )

      receiver.broadcast_notification_badge
      receiver.broadcast_notification_dropdown

    elsif @friend_request.receiver == current_user
      @friend_request.destroy

      current_user.remove_friend_request_notification(
        friend_request_id
      )

      current_user.broadcast_notification_badge
      current_user.broadcast_notification_dropdown
    end

    respond_to do |format|
      format.html do
        redirect_back fallback_location: root_path
      end

      format.turbo_stream { head :ok }
    end
  end
end
