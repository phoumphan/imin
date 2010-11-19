class ChangeFriendshipColumnName < ActiveRecord::Migration
  def self.up
    rename_column :friendships, :userA_id, :user_id
    rename_column :friendships, :userB_id, :friend_id
  end

  def self.down
    rename_column :friendships, :user_id, :userA_id
    rename_column :friendships, :friend_id, :userB_id
  end
end
