class PendingFriendRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :requester, :class_name => "User"
end
