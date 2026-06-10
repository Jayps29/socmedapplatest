class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :avatar
  has_many :posts, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :active_follows,
         class_name: "Follow",
         foreign_key: :follower_id,
         dependent: :destroy

has_many :passive_follows,
         class_name: "Follow",
         foreign_key: :followed_id,
         dependent: :destroy

has_many :following,
         through: :active_follows,
         source: :followed

has_many :followers,
         through: :passive_follows,
         source: :follower

  def following?(user)
   active_follows.exists?(followed: user)
  end

  has_many :sent_friend_requests,
         class_name: "FriendRequest",
         foreign_key: :sender_id,
         dependent: :destroy

has_many :received_friend_requests,
         class_name: "FriendRequest",
         foreign_key: :receiver_id,
         dependent: :destroy

  def friend_request_sent_to?(user)
    sent_friend_requests.exists?(
      receiver: user,
      status: :pending
    )
  end

  def friend_request_from?(user)
    received_friend_requests.exists?(
      sender: user,
      status: :pending
    )
  end

  def pending_friend_request_with(user)
    FriendRequest.find_by(
      sender: self,
      receiver: user,
      status: :pending
    ) ||
    FriendRequest.find_by(
      sender: user,
      receiver: self,
      status: :pending
    )
  end

  has_many :friendships,
         dependent: :destroy

  has_many :friends,
         through: :friendships,
         source: :friend



  def friendship_with(user)
    friendships.find_by(friend: user)
  end

  def friends_with?(user)
  friends.include?(user)
  end

  def feed_users
    (following.ids + friends.ids + [ id ]).uniq
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      username
      first_name
      last_name
      created_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  has_many :notifications,
         as: :recipient,
         class_name: "Noticed::Notification",
         dependent: :destroy


        def broadcast_notification(message, type, url)
          broadcast_notification_badge
          broadcast_notification_toast(message, type, url)
        end

        def broadcast_notification_badge
          Turbo::StreamsChannel.broadcast_replace_to(
            self,
            target: "notification_badge",
            partial: "notifications/badge",
            locals: {
              current_user: self
            }
          )
        end

        def broadcast_notification_toast(message, type, url)
          Turbo::StreamsChannel.broadcast_append_to(
            self,
            target: "toast_notifications",
            partial: "notifications/toast",
            locals: {
              message: message,
              type: type,
              url: url
            }
          )
        end
end
