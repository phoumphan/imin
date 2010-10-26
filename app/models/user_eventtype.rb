class UserEventtype < ActiveRecord::Base

  #user and eventtype (many-to-many) associations
  belongs_to :user
  belongs_to :eventtype
end
