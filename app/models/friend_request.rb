class FriendRequest < ApplicationRecord
  belongs_to :sender,
             class_name: "User"

  belongs_to :receiver,
             class_name: "User"

  enum :status,
       {
         pending: 0,
         accepted: 1,
         declined: 2
       }

  validates :sender_id,
            uniqueness: {
              scope: :receiver_id
            }
end
