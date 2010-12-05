class Event < ActiveRecord::Base
  
  has_event_calendar

  #User associations (many-to-many)
  has_many :user_events, :dependent => :destroy
  has_many :users, :through => :user_events

  #eventtype associations (many-to-many)
  has_many :event_eventtypes, :dependent => :destroy
  has_many :eventtypes, :through => :event_eventtypes

  #photo associations (many-to-many)
  has_many :event_photos, :dependent => :destroy
  has_many :photos, :through => :event_photos

  has_many :event_ratings, :dependent => :destroy

  belongs_to :owner, :class_name => "User"

  validates_presence_of :name
  validates_presence_of :description
  validates_numericality_of :cost, :greater_than_or_equal_to => 0

  define_index do
    indexes name, :sortable => true
    indexes formality
    indexes eventtypes.description  

    set_property :delta => true
  end

  # Creator is the id of the person who created the relationship. Usr is id of user who is involved
  # in the relationship. E.g., 'Creator' invited 'usr' to this event.
  # Generally when usr is current_user.id, creator should be nil, so a notice doesn't show up
  # for them doing an action on their own account.
  def create_relationship(usr, creator, status)
      if not UserEvent.find(:first, :conditions => {:event_id => id, :user_id => usr, :user_event_status => name})
        user_event = UserEvent.new
        user_event.user_id = usr
        user_event.user_event_status = status
        user_event.creator = creator
        return false if not user_event.save
        user_events << user_event
      end
      return true
  end

  def self.hash_coord(x)
    (x / 0.005).floor
  end

  def self.hash_loc(loc)
    # Computes which bin a location is in
    loc.split(',').map { |x| hash_coord (x.to_f) }
  end

  # loc is lat & lng, comma separated
  def self.closest_to(loc)
    # Find events in bins near given point's bin 
    binvals = hash_loc loc

    # Get events near loc using hash values saved with the events
    closest = []
    [-1, 0, 1].each do |x|
      [-1, 0, 1].each do |y|
        closest.concat(Event.find(:all, :conditions => {:bin_lat => binvals[0] + y, :bin_lng => binvals[1] + x}))
      end
    end

    # Order these by straight-line distance to loc
    userlatlng = loc.split(',').map { |x| x.to_f }
    return closest.sort_by do |ev|
      latlng = ev.location.split(',').map { |x| x.to_f }
      (latlng[0] - userlatlng[0]) ** 2 + (latlng[1] - userlatlng[1]) ** 2
    end
  end
end
