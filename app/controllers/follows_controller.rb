class FollowsController < ApplicationController
    before_action :authenticate_user!

    def create
        user = User.find(params[:user_id])

        return redirect_back(fallback_location: root_path) if user == current_user

        current_user.active_follows.create!(
          followed: user
        )

        FollowNotifier.with(
        follower: current_user
        ).deliver(user)



        user.broadcast_notification_badge

        redirect_back fallback_location: root_path
      end

    def destroy
      follow = current_user.active_follows.find(params[:id])

      follow.destroy

      redirect_back fallback_location: root_path
    end

    def remove_follower
        follow = Follow.find(params[:id])

        if follow.followed == current_user
          follow.destroy
        end

        redirect_back fallback_location: root_path
      end
end
