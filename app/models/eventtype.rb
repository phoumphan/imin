class Eventtype < ActiveRecord::Base

  validates_presence_of :description
  
  #User associations (many-to-many)
  has_many :user_eventtypes
  has_many :users, :through => :user_eventtypes

  #Event associations (many-to-many)
  has_many :event_eventtypes
  has_many :events, :through => :event_eventtypes
end
