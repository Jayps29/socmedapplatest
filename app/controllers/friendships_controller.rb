class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource

  def destroy
    Friendship.where(
      user: @friendship.friend,
      friend: current_user
    ).destroy_all

    @friendship.destroy

    redirect_back fallback_location: root_path
  end
end
