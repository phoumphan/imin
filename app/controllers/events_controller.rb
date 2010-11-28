class EventsController < ApplicationController
  before_filter :login_required, :except => [:show, :showphoto]
  
  #render new.html.erb
  def new
    @event = Event.new
    @event_eventtype = @event.event_eventtypes.new
    # @event_photo = @event.event_photos.new
    @event.cost = 0

    set_friends
  end

  #Action that actually creates the Event once the user Submits the event
  def create
    @event = Event.new(params[:event])

    #Create rows in EventEventtypes
    if params[:event_eventtype] != nil
      params[:event_eventtype].each { |p| @event.event_eventtypes << EventEventtype.new( p ) }
    end
    
    # #Create rows in EventPhotos
    # if params[:event_photo] != nil
    #   params[:event_photo].each { |p| @event.event_photos << EventPhoto.new( p ) }
    # end
  	
    #Create rows in UserEvents
    #Ids retrieved before creating joins, to stop space leaks
    ids = params[:user_events].split(',').map { |nm|
      usr = User.find_by_login(nm)
      if not usr
        flash[:error] = "No such user: " + nm # TODO flash doesn't show up
        redirect_to :action => 'new', :id => @event.id
        return
      end
      usr.id
    }
    ids.each { |i|
      user_event = UserEvent.new
      user_event.user_id = i
      user_event.user_event_status = "INVITED"
      return unless user_event.save
      @event.user_events << user_event
    }

    #owner ID is stored in the Events table
    #Creator is an admin
    user_event = UserEvent.new
    user_event.user_id = current_user.id
    user_event.user_event_status = "ADMIN"
    return unless user_event.save
    @event.user_events << user_event

    @event.owner = current_user

    #Hash location
    binvals = UsersController.hash_loc @event.location
    @event.bin_lat = binvals[0]
    @event.bin_lng = binvals[1]

    #redirect to the event page
    if @event.save
  	   redirect_to :action => 'show', :id => @event.id
    end

  end

  def show
    @event = Event.find(params[:id])
    latlng = @event.location.split(',')
    @lat = latlng[0]
    @lng = latlng[1]
  end

  #Action that results in rendering the event_eventtypes/_new.html.erb partial
  def add_eventtype
    @event_eventtype = EventEventtype.new()
  end

  #Renders events/edit.html.erb
  def edit
    @event = Event.find(params[:id])
    @event_eventtype = @event.event_eventtypes.find(:all, :conditions => {:event_id => params[:id]})
    @event_photo = @event.event_photos.find(:all, :conditions => {:event_id => params[:id]})
    @event_users = @event.user_events.find(:all, :conditions => {:event_id => params[:id]})

    #location coordinates
    latlng = @event.location.split(',')
    @lat = latlng[0]
    @lng = latlng[1]
  end

  #Action that is called once the user is done editing the Event
  def update
    @event = Event.find(params[:id])

    #Updated existing event types, photos, and invitations
    params[:event_eventtypes_update].each { |key, value| EventEventtype.find( key ).update_attributes(value)} if params[:event_eventtypes_update]
    params[:event_photos_update].each { |key, value| EventPhoto.find( key ).update_attributes(value) } if params[:event_photos_update]
    params[:event_users_update].each { |key, value| UserEvent.find( key ).update_attributes(value) } if params[:event_users_update]

    #New event types, photos, invitations that could get sent out
    params[:event_eventtype].each { |p| @event.event_eventtypes << EventEventtype.new( p ) } if params[:event_eventtype]
  	params[:event_photo].each { |p| @event.event_photos << EventPhoto.new( p ) } if params[:event_photo]
    params[:event_users].each { |p| @event.user_events << UserEvent.new( p ) } if params[:event_users]

    #Hash location
    binvals = UsersController.hash_loc @event.location
    @event.bin_lat = binvals[0]
    @event.bin_lng = binvals[1]

  	if @event.update_attributes(params[:event])
      flash[:notice] = "Event Successfully Updated"
  	  redirect_to :action => 'show', :id => @event.id
	  else
      render :action => 'edit', :id => params[:id]
	  end
  end

  private

  def owner_check
    if @event.owner.id != current_user.id
      flash[:error] = "You are not the owner"
      redirect_to(:action => session[:referrer], :id => @event.id)
      false
    else
      true
    end
  end

  def admin_check
    if not UserEvent.find_by_event_id_and_user_event_status(@event.id, "ADMIN")
      flash[:error] = "You are not an admin"
      redirect_to(:action => session[:referrer], :id => @event.id)
      false
    else
      true
    end
  end

  def set_friends
    return if current_user.id =~ /[^\d]/
    friend_objs = Friendship.find(:all, :conditions => 'user_id = ' + current_user.id.to_s)
    @friends = {}
    friend_objs.each do |frnd|
      @friends[User.find(frnd.friend_id).login] = frnd.friend_id
    end
  end

  public

  def invite_user
    @event = Event.find(params[:id])
    @action_name = 'Invite a User'
    @user_status = 'INVITED'
    session[:referrer] = 'invite_user'
    set_friends

    respond_to do |format|
      format.html { render "add_user_to" }
      format.xml { head :ok }
    end
  end

  def add_admin
    @event = Event.find(params[:id])
    @action_name = 'Add an Admin'
    @user_status = 'ADMIN'
    session[:referrer] = 'add_admin'
    set_friends

    respond_to do |format|
      format.html { render "add_user_to" }
      format.xml { head :ok }
    end
  end

  def user_add_exec
    @event = Event.find(params[:id])
    if params[:user_status] == 'ADMIN'
      return unless admin_check
    else
      return unless owner_check
    end
    if params[:friend] == '1'
      usr = User.find(params[:friend])
    else
      usr = User.find_by_login(params[:other_user])
    end
    if usr
      join = UserEvent.new
      join.user_id = usr.id
      join.event_id = params[:id]
      return if params[:user_status] != "ADMIN" and params[:user_status] != "INVITED"
      join.user_event_status = params[:user_status]
      if join.save
        if params[:user_status] == "ADMIN"
          flash[:notice] = 'Admin added'
        else
          flash[:notice] = 'User invited'
        end
        redirect_to :action => 'show', :id => @event.id
      else
        flash[:error] = 'Unknown error'
        redirect_to :action => 'invite_user', :id => @event.id
      end
    else
      flash[:error] = 'User does not exist'
      redirect_to :action => 'invite_user', :id => @event.id
    end
  end

  def invite_user

  end

end
