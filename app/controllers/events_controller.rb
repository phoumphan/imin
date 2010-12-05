class EventsController < ApplicationController
  before_filter :login_required, :except => [:show, :showphoto]
  
  #render new.html.erb
  def new
    @event = Event.new
    @event_eventtype = @event.event_eventtypes.new
    # @event_photo = @event.event_photos.new
    @event.cost = 0

    # set up friend choices for invitations
    set_friends

    @invited = []
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
        flash.now[:error] = "No such user: " + nm

        reload_new_form
        return
      end
      usr.id
    }
    ids.each { |i|
      return unless @event.create_relationship(i, current_user, "INVITED")
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
    binvals = Event.hash_loc @event.location
    @event.bin_lat = binvals[0]
    @event.bin_lng = binvals[1]

    #redirect to the event page
    if @event.save
  	   redirect_to :action => 'show', :id => @event.id
    else
      flash.now[:error] = "Error while saving event"
      reload_new_form
    end

  end

  def show

    @event = Event.find(params[:id])

    # Check that user is allowed to view this event
    @admin_status = is_admin
    if current_user
      invite_status = UserEvent.find(:first, :conditions => {:event_id => @event.id, :user_id => current_user.id, :user_event_status => "INVITED"})
    else
      invite_status = nil
    end
    if @event.privacy == 'Public' or @admin_status or invite_status
      latlng = @event.location.split(',')
      @lat = latlng[0]
      @lng = latlng[1]

      if current_user
        @already_rated = false
        @user_rating = EventRating.all(:conditions => {:event_id => params[:id], :user_id => current_user.id})
        if (@user_rating.size != 0)
          @already_rated = true
        end
      end

      @number_of_ratings = EventRating.find_by_sql('SELECT COUNT(*) FROM event_ratings WHERE event_id = ' + @event.id.to_s)[0]["COUNT(*)"].to_i

      # Referrer is for redirects on admin_check and owner_check errors
      session[:referrer] = 'show'

    #-----------WEATHER-------------
    location_url = "http://where.yahooapis.com/v1/places.q('vancouver%20bc%20canada')?appid=[PMelBrV34F.SL0PzMHeJo5kYOhR6FDbRAzDZuppSO9gSfK_MM8Hssnw8A3kkoNY57uk]"
    location_resp = Net::HTTP.get_response(URI.parse(location_url))
    #location_data = location_resp.body
    xml_location_data = Net::HTTP.get_response(URI.parse(location_url)).body
    location_doc = REXML::Document.new(xml_location_data)
    woeids = []
    location_doc.elements.each('places/place/woeid') do |ele|
       woeids << ele.text
    end
    puts('----WOEID----');
    puts woeids[0]
    @woeid = woeids[0]

    #Information for Weather
    puts("-------------------GOT TO WEATHER-----------------------")
    url="http://weather.yahooapis.com/forecastrss?w=#@woeid&u=c"
    resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object
    data = resp.body
    xml_data = Net::HTTP.get_response(URI.parse(url)).body

    doc = REXML::Document.new(xml_data)
    titles = []
    links = []
    doc.elements.each('rss/channel/item/description') do |ele|
       @description = ele.text
    end
    puts('-------Description---------')
    puts @description;

      @coming = @event.user_events.find(:all, :conditions => {:user_event_status => 'COMING'}).map {|join| join.user}
    else
      flash[:error] = "You are not allowed to view that event"
      redirect_to :controller => 'users', :action => 'profile'
    end
  end

  def rate
    @event_rating = EventRating.new(:event_id => params[:id], :user_id => current_user.id)

    if @event_rating.save
      flash[:notice] = "You think this event is good stuff!"
    end
    redirect_to :action => 'show', :id => params[:id]
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
    #@event_users = @event.user_events.find(:all, :conditions => {:event_id => params[:id]})

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
    #params[:event_users_update].each { |key, value| UserEvent.find( key ).update_attributes(value) } if params[:event_users_update]

    #New event types, photos, invitations that could get sent out
    params[:event_eventtype].each { |p| @event.event_eventtypes << EventEventtype.new( p ) } if params[:event_eventtype]
  	params[:event_photo].each { |p| @event.event_photos << EventPhoto.new( p ) } if params[:event_photo]
    #params[:event_users].each { |p| @event.user_events << UserEvent.new( p ) } if params[:event_users]

    #Hash location
    binvals = Event.hash_loc @event.location
    @event.bin_lat = binvals[0]
    @event.bin_lng = binvals[1]

    if @event.update_attributes(params[:event])
      redirect_to :action => 'show', :id => @event.id
    else
      flash.now[:notice] = "Unknown error"
      render :action => 'edit', :id => params[:id]
    end
  end

  def deletion
    @event = Event.find(params[:id])
    if owner_check
      @event.destroy
      redirect_to :controller => 'users', :action => 'profile'
    end
  end

  private

  def reload_new_form
        # Reload 'new' form on error message
        set_friends
        @invited = params[:user_events].split(',')
        respond_to do |form|
          form.html { render :action => 'new' }
          form.xml { head :ok }
        end
  end

  def owner_check
    if not current_user or @event.owner.id != current_user.id
      flash[:error] = "You are not the owner"
      redirect_to(:action => session[:referrer], :id => @event.id)
      false
    else
      true
    end
  end

  def is_admin
    if current_user
      UserEvent.find(:first, :conditions => {:event_id => @event.id, :user_id => current_user.id, :user_event_status => "ADMIN"})
    else
      nil
    end
  end

  def admin_check
    if not is_admin
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

  def error_dest(status)
    if status == 'ADMIN'
      'add_admin'
    else
      'invite_user'
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

  # Action run when inviting a user (after event is created)
  # and adding an admin. A hidden field in the add_user_to
  # partial determines which.
  def user_add_exec
    @event = Event.find(params[:id])
    return unless admin_check
    if params[:friend] == '1'
      # User selected in dropdown list
      usr = User.find(params[:friend_select])
    else
      # User typed a name
      usr = User.find_by_login(params[:other_user])
    end
    if usr
      return if params[:user_status] != "ADMIN" and params[:user_status] != "INVITED" # validate input

      if @event.create_relationship(usr.id, current_user, params[:user_status])
        if params[:user_status] == "ADMIN"
          flash[:notice] = 'Admin added'
        else
          flash[:notice] = 'User invited'
        end
        redirect_to :action => 'show', :id => @event.id
      else
        flash[:error] = 'Unknown error'
        redirect_to :action => error_dest(params[:user_status]), :id => @event.id
      end
    else
      flash[:error] = 'User does not exist'
      redirect_to :action => error_dest(params[:user_status]), :id => @event.id
    end
  end

end
