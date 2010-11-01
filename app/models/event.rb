class Event < ActiveRecord::Base
  #User associations (many-to-many)
  has_many :user_events
  has_many :users, :through => :user_events

  #eventtype associations (many-to-many)
  has_many :event_eventtypes
  has_many :eventtypes, :through => :event_eventtypes

  #photo associations (many-to-many)
  has_many :event_photos
  has_many :photos, :through => :event_photos

  validates_presence_of :name
  validates_presence_of :description
end
