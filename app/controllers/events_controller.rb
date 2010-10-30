class EventsController < ApplicationController
  
  #render new.html.erb
  def new
    @event = Event.new
    @event_eventtype = @event.event_eventtype.new
    @event_photo = @event.event_photo.new
  end

  def create
    
  end
end
