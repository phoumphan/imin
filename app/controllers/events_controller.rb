class EventsController < ApplicationController
  
  #render new.html.erb
  def new
    @event = Event.new
    @event_eventtype = @event.event_eventtypes.new
    @event_photo = @event.event_photos.new
    @event_users = @event.user_events.new
  end

  def create
    @event = Event.new(params[:event])

    #Create rows in EventEventtypes
    if params[:event_eventtype] != nil
      params[:event_eventtype].each { |p| @event.event_eventtypes << EventEventtype.new( p ) }
    end
    
    #Create rows in EventPhotos
    if params[:event_photo] != nil
      params[:event_photo].each { |p| @event.event_photos << EventPhoto.new( p ) }
    end
  	
    #Create rows in UserEvents
    if params[:event_users] != nil
      params[:event_users].each { |p| @event.event_users << UserEvent.new(p)}
    end

    #redirect to the event page
    if @event.save
  	   redirect_to :action => 'show', :id => @event.id
    end


  end

  def show
    @event = Event.find(params[:id])
  end

  def add_eventtype
    @event_eventtype = EventEventtype.new()
  end

  def invite_users

  end
  
end
