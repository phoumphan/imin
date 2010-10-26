class Photo < ActiveRecord::Base

  #event associations (many-to-many)
  has_many :event_photos
  has_many :events, :through => :event_photos
end
