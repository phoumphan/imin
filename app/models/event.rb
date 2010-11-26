class Event < ActiveRecord::Base
  
  has_event_calendar

  #User associations (many-to-many)
  has_many :user_events
  has_many :users, :through => :user_events

  #eventtype associations (many-to-many)
  has_many :event_eventtypes
  has_many :eventtypes, :through => :event_eventtypes

  #photo associations (many-to-many)
  has_many :event_photos
  has_many :photos, :through => :event_photos

  belongs_to :owner, :class_name => "User"

  validates_presence_of :name
  validates_presence_of :description
  validates_numericality_of :cost, :greater_than_or_equal_to => 0

  define_index do
    indexes name, :sortable => true
  end
end
