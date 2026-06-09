class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def dropdown
    @notifications = current_user.notifications
                                 .includes(:event)
                                 .order(created_at: :desc)
                                 .limit(20)

    render partial: "notifications/dropdown"
  end

  def mark_read
    current_user.notifications.unread.mark_as_read

    current_user.broadcast_notification_badge

    head :ok
  end

  def index
    current_user.notifications.unread.mark_as_read

    @notifications = current_user.notifications
                                 .includes(:event)
                                 .order(created_at: :desc)
  end
end
