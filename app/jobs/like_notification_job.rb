class LikeNotificationJob < ApplicationJob
  queue_as :default

  def perform(post_id, liker_id)
    post = Post.find_by(id: post_id)
    liker = User.find_by(id: liker_id)

    return unless post && liker

    LikeNotifier.with(
      user: liker,
      post: post
    ).deliver(post.user)

    post.user.broadcast_notification(
      "#{liker.username} liked your post",
      "like",
      Rails.application.routes.url_helpers.post_path(post)
    )
  end
end
