class FriendshipsController < ApplicationController
    before_action :authenticate_user!

    def destroy
      friendship = current_user.friendships.find(params[:id])

      Friendship.where(
        user: friendship.friend,
        friend: current_user
      ).destroy_all

      friendship.destroy

      redirect_back fallback_location: root_path
    end
end
