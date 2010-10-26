class UserEvent < ActiveRecord::Base

  #users and events (many-to-many) associations
  belongs_to :user
  belongs_to :event
end
