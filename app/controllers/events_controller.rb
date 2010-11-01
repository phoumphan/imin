class EventsController < ApplicationController
  
  #render new.html.erb
  def new
    @event = Event.new
    @event_eventtype = @event.event_eventtypes.new
    @event_photo = @event.event_photos.new
    @event_users = @event.user_events.new
  end

  def create
    
  end

  def show
    
  end
end
