class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(post_id, comment_id, commenter_id)
    post = Post.find_by(id: post_id)
    comment = Comment.find_by(id: comment_id)
    commenter = User.find_by(id: commenter_id)

    return unless post && comment && commenter

    CommentNotifier.with(
      user: commenter,
      post: post,
      comment: comment
    ).deliver(post.user)

    post.user.broadcast_notification(
      "#{commenter.username} commented on your post",
      "comment",
      Rails.application.routes.url_helpers.post_path(post)
    )
  end
end
