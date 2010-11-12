class EventsController < ApplicationController

  
  #render new.html.erb
  def new
    @event = Event.new
    @event_eventtype = @event.event_eventtypes.new
    @event_photo = @event.event_photos.new
    @event_users = @event.user_events.new
    @event.cost = 0
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

    @event.owner = current_user

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

  private

  def login_check
    if current_user
      true
    else
      flash[:error] = "Not logged in"
      redirect_to(:action => session[:referrer], :id => @event.id)
      false
    end
  end

  def owner_check
    if login_check
      if @event.owner.id != current_user.id
        flash[:error] = "You are not the owner"
        redirect_to(:action => session[:referrer], :id => @event.id)
        return false
      end
      true
    else
      false
    end
  end

  public

  def invite_user
    @event = Event.find(params[:id])
    @action = 'invite_user_exec'
    @action_name = 'Invite a User'
    @friends = Friendship.find(:all, :conditions => "userA_id = " + current_user.id.to_s)
    session[:referrer] = 'invite_user'

    respond_to do |format|
      format.html { render "add_user_to" }
      format.xml { head :ok }
    end
  end

  def invite_user_exec
    @event = Event.find(params[:id])
    return unless owner_check
    if params[:friend] == '1'
      usr = User.find(params[:user_id])
    else
      usr = User.find_by_login(params[:other_user])
    end
    if usr
      join = UserEvent.new
      join.user_id = usr.id
      join.event_id = params[:id]
      join.user_event_status = "INVITED"
      if join.save
        flash[:notice] = 'User invited'
      else
        flash[:error] = 'Unknown error'
      end
    else
      flash[:error] = 'User does not exist'
    end
    redirect_to :action => 'show', :id => @event.id
  end
  
end
