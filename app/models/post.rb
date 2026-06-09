class Post < ApplicationRecord
  belongs_to :user

  validates :content,
            presence: true,
            length: { maximum: 5000 }

  has_many_attached :images
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  scope :feed_for, ->(user) {
  where(user_id: user.feed_users)
  }
end
