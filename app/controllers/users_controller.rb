class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include Geokit::Geocoders

  require 'net/http'
  require 'rexml/document'
  require 'geokit'

  before_filter :login_required, :except => [:new, :create, :forgot_password]

  # render new.
  # called when "register" link is clicked
  def new
    @user = User.new
  end

  # Method to actually create the user, called from the new.rhtml page once the submit button is pressed
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
            # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  #render users/profile
  def profile
    @user = current_user

    #information for Map
    latlng = @user.location.split(',')
    @lat = latlng[0]
    @lng = latlng[1]

    #Information for location

    res = GoogleGeocoder.reverse_geocode([@lat,@lng])
    @location = res.full_address

    puts('----------LOCATION-----------');
    puts @location
    location_array = @location.split(/, /)
    puts location_array[0]
    @city = location_array[0]
    puts('----------city-----------');
    puts @city

    puts location_array[1]
    province_array = location_array[1].split(/ /);
    @province = province_array[0]
    puts('----------province-----------');
    puts @province

    puts location_array[2]
    @country = location_array[2]
    puts('----------country-----------');
    puts @country

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

    doc.elements.each('rss/channel/item/yweather:condition') do |ele|
       links << ele.text
       @temperature = ele.attributes["temp"]
       puts('-------TEMPERATURE---------')
       puts @temperature
    end

    #Information for Event Calendar
    if (params[:month] && params[:year])
      @month = params[:month].to_i
      @year = params[:year].to_i
    else
      time = Time.new
      @month = time.month
      @year = time.year
    end

    @shown_month = Date.civil(@year, @month)
    # To restrict what events are included in the result you can pass additional find options like this:
    # @event_strips = Event.event_strips_for_month(@shown_month, :include => :some_relation, :conditions => 'some_relations.some_column = true')
    
    #1.  Need to get all the Event ids that user is attending
    @user_events = Array.new
    
    user_event_rows = UserEvent.find_all_by_user_id(current_user.id)
    for ue in user_event_rows
      @user_events << ue.event_id.to_s
    end    

    #@event_strips = Event.event_strips_for_month(@shown_month)
    @event_strips = Event.event_strips_for_month(@shown_month, :conditions => ["id IN (?)", @user_events])

    #Notices
    #Notify the user of newly created statuses in UserEvent
    temp = UserEvent.find_by_sql('SELECT * FROM user_events WHERE user_id = ' + current_user.id.to_s + ' ORDER BY created_at DESC LIMIT 15;')
    @notices = []
    temp.each do |notice|
      @notices << notice if notice.creator_id
    end
  end

  def events
    if current_user
      @user = current_user

      #location coordinates
      latlng = @user.location.split(',')
      @lat = latlng[0]
      @lng = latlng[1]
    else
      redirect_to(login_path)
    end

    @user_events = Event.find(:all, :conditions => :owner == @user.id);
     puts('----USER EVENTS------');
  end

  #render users/edit_info
  def edit_info
    if current_user
      @user = current_user

      #location coordinates
      latlng = @user.location.split(',')
      @lat = latlng[0]
      @lng = latlng[1]
    else
      redirect_to(login_path)
    end
  end

  #render users/preferences
  def preferences
    if current_user
      @user = current_user
    else
      redirect_to(login_path)
    end
  end

  #method that will be called from the users/preferences.html.erb page when "update" link is clicked
  def update_preferences
    @user = current_user    
    @updated_user_event_tag = UserEventtype.find(:all, :conditions => :user_id == @user.id);
    

    @updated_user_event_tag = UserEventtype.find(:all, :conditions => :user_id == @user.id);
    puts('----@user_event_tags----')
    puts @updated_user_event_tag
    @updated_user_event_tag.each do |event_tag|
      if (event_tag.eventtype_id != params[:tag_ids] && event_tag.user_id == @user.id)
        event_tag.destroy
      end
    end

    #bug here when update info
    params[:tag_ids].each do |p|
      puts(p.to_s)
      @user.user_eventtypes << UserEventtype.new( :user_id => current_user.id, :eventtype_id=>p )
    end
    @updated_user_event_tag = UserEventtype.find(:all, :conditions => :user_id == @user.id);
    i = 0;
    @updated_tag_ids = {}
    @updated_user_event_tag.each do |e|
      @updated_tag_ids[i] = e.eventtype_id
      i = i+1
    end
  end

  def update
    @user = current_user
    puts(params[:user])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Profile Successfully Updated"
      redirect_to :action => 'profile'
    else
      redirect_to :action => 'edit_info'
      flash[:error] = "Profile Update failed"
    end
  end

  #method used to change user password.  Called from users/edit_info.html.erb page when
  #"change password" link is clicked
  def update_password
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Password Successfully Updated"
      redirect_to :action => 'edit_info', :id => @user.id
    else
      render :action => 'change_password', :id => params[:id]
    end
  end

  def change_password
    @user = current_user
  end

  def forgot_password
    
    return unless request.post?
    if @user = User.find_by_email(params[:user][:email])
      @user.forgot_password
      @user.save
      redirect_back_or_default('/')
      flash[:notice] = "A password reset link has been sent to your email address"
    else
      flash[:alert] = "Could not find a user with that email address"
    end
  end

  def show
    @friend = User.find(params[:id])
    if current_user
      @user = current_user
    else
      redirect_to(login_path)
    end
    
    #If a user tries to view himself, it will redirect to his profile page
    if (@friend.id == current_user.id)
      redirect_to (profile_page_path)
    end

    #Information for Event Calendar
    if (params[:month] && params[:year])
      @month = params[:month].to_i
      @year = params[:year].to_i
    else
      time = Time.new
      @month = time.month
      @year = time.year
    end

    @shown_month = Date.civil(@year, @month)
    # To restrict what events are included in the result you can pass additional find options like this:
    # @event_strips = Event.event_strips_for_month(@shown_month, :include => :some_relation, :conditions => 'some_relations.some_column = true')

    #1.  Need to get all the Event ids that user is attending
    @user_events = Array.new

    user_event_rows = UserEvent.find_all_by_user_id(@friend.id)
    for ue in user_event_rows
      @user_events << ue.event_id.to_s
    end    

    #@event_strips = Event.event_strips_for_month(@shown_month)
    @event_strips = Event.event_strips_for_month(@shown_month, :conditions => ["id IN (?)", @user_events])

  end

  def closestevents
    @center = current_user.location
    @closest = Event.closest_to current_user.location
  end

end
