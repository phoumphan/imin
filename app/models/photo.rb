class Photo < ActiveRecord::Base

  #event associations (many-to-many)
  has_many :event_photos
  has_many :events, :through => :event_photos

  belongs_to :owner, :class_name => "User"

  has_attached_file :photo,
    :path => ':rails_root/public/images/photos/:id/:style_:basename.:extension',
    :url => ':class/:id/:style_:basename.:extension',
    :styles => { :medium => "400x400>" }

  # This code taken from http://railscasts.com/episodes/134-paperclip
  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/pjpeg', 'image/jpeg', 'image/png', 'image/gif']

end
