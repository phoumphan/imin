class Photo < ActiveRecord::Base

  #event associations (many-to-many)
  has_many :event_photos
  has_many :events, :through => :event_photos

  has_attached_file :photo, :styles => { :thumb => "300x300>" }

  # This code taken from http://railscasts.com/episodes/134-paperclip
  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif']

end
