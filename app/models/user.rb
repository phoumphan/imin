require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  #Pending friend request associations
  has_many :invitations
  has_many :invites, :through => :invitations

  #Pending friend request associations
  has_many :pending_friend_requests
  has_many :requesters, :through => :pending_friend_requests

  #Friendship associations (self - referencing)
  has_many :friendships
  has_many :friends, :through => :friendships

  #Event associations (many-to-many)
  has_many :user_events
  has_many :events, :through => :user_events

  has_many :owned_events, :class_name => "Event"
  has_many :owned_photos, :class_name => "Photo"

  #Eventtype associations (many-to-many)
  has_many :user_eventtypes
  has_many :eventtypes, :through => :user_eventtypes

  has_many :event_ratings

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  has_attached_file :photo, :default_url => "/images/default.jpg",
    :styles => {:thumb => "50x50#",
                :small  => "150x150>",
                :medium => "200x200>",
                :large => "400x400>" }

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :location, :photo
  
  define_index do
    indexes login, :sortable => true
    indexes name, :sortable => true

    set_property :delta => true
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

   
end
