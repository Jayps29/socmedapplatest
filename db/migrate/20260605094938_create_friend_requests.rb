class CreateFriendRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :friend_requests do |t|
      t.references :sender,
                   null: false,
                   foreign_key: {
                     to_table: :users
                   }

      t.references :receiver,
                   null: false,
                   foreign_key: {
                     to_table: :users
                   }

      t.integer :status,
                default: 0,
                null: false

      t.timestamps
    end

    add_index :friend_requests,
              [ :sender_id, :receiver_id ],
              unique: true
  end
end
