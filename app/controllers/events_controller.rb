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

    #Creator is an admin
    user_event = UserEvent.new
    user_event.user_id = current_user.id
    user_event.user_event_status = "ADMIN"
    return unless user_event.save
    @event.user_events << user_event

    @event.owner = current_user

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

  def admin_check
    if login_check
      if not UserEvent.find_by_event_id_and_user_event_status(@event.id, "ADMIN")
        flash[:error] = "You are not an admin"
        redirect_to(:action => session[:referrer], :id => @event.id)
        return false
      end
      true
    else
      false
    end
  end

  def set_friends
    return if current_user.id =~ /[^\d]/
    friend_objs = Friendship.find(:all, :conditions => 'userA_id = ' + current_user.id.to_s)
    @friends = {}
    friend_objs.each do |frnd|
      @friends[User.find(frnd.userB_id).login] = frnd.userB_id
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
  
end
