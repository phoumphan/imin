class EventEventtype < ActiveRecord::Base

  #event and eventtype associations (many-to-many)
  belongs_to :event
  belongs_to :eventtype
end
