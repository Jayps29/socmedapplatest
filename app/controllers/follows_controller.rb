class FollowsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource except: [ :create ]

  def create
    user = User.find(params[:user_id])

    return redirect_back(fallback_location: root_path) if user == current_user

    @follow = current_user.active_follows.build(
      followed: user
    )

    authorize! :create, @follow

    @follow.save!

    FollowNotifier.with(
      follower: current_user
    ).deliver(user)

    user.broadcast_notification(
      "#{current_user.username} followed you",
      "follow",
      profile_path(current_user)
    )

    redirect_back fallback_location: root_path
  end

  def destroy
    @follow.destroy

    redirect_back fallback_location: root_path
  end

  def remove_follower
    authorize! :remove_follower, @follow

    @follow.destroy

    redirect_back fallback_location: root_path
  end
end
