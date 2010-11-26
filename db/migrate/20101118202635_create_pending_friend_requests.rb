class CreatePendingFriendRequests < ActiveRecord::Migration
  def self.up
    create_table :pending_friend_requests do |t|
      t.integer :user_id
      t.integer :requester_id
      t.timestamps
    end
  end

  def self.down
    drop_table :pending_friend_requests
  end
end
