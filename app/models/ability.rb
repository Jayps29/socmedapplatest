class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # Public permissions
    can :read, :all

    return unless user.persisted?

    # Admin
    if user.has_role?(:admin)
      can :manage, :all
      return
    end

    # User Profile
    can :update, User, id: user.id

    # Posts
    can :create, Post
    can %i[update destroy], Post, user_id: user.id

    # Comments
    can :create, Comment
    can :update, Comment, user_id: user.id

    can :destroy, Comment do |comment|
      comment.user_id == user.id ||
        comment.post.user_id == user.id
    end

    # Likes
    can :create, Like
    can :destroy, Like, user_id: user.id

    # Follows
    can :create, Follow
    can :destroy, Follow, follower_id: user.id

    can :remove_follower, Follow do |follow|
      follow.followed_id == user.id
    end

    # Friend Requests
    can :create, FriendRequest

    can :accept, FriendRequest do |request|
      request.receiver_id == user.id
    end

    can :destroy, FriendRequest do |request|
      request.sender_id == user.id ||
        request.receiver_id == user.id
    end

    # Friendships
    can :destroy, Friendship do |friendship|
      friendship.user_id == user.id ||
        friendship.friend_id == user.id
    end

    # Notifications
    can :read, Noticed::Notification do |notification|
      notification.recipient == user
    end

    can :update, Noticed::Notification do |notification|
      notification.recipient == user
    end
  end
end
