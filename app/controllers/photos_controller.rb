class PhotosController < ApplicationController
  before_filter :login_required, :except => [:show, :image]

  def new
    @photo = Photo.new
    @first_event = Event.find(params[:id])
  end

  def edit
    @photo = Photo.find(params[:id])
  end

  private

  def photo_access
    # A photo is available if it belongs to a public event, or if it
    # belongs to an event of which the user is an invitee/admin
    if current_user
      usr_id = current_user.id
      return false if usr_id =~ /[^X\d]/ # security check
      usr_id = usr_id.to_s
    else
      usr_id = '-1'
    end
    return false if params[:id] =~ /[^\d]/ # security check
    authorizations = ActiveRecord::Base.connection().execute("SELECT * FROM (events JOIN event_photos ON events.id = event_photos.event_id)
      JOIN user_events ON events.id = user_events.event_id
      WHERE photo_id = " + params[:id] + " AND (public = 1 OR (user_id = " + usr_id + " AND (user_event_status = 'INVITED' OR user_event_status = 'ADMIN')))")
    return authorizations.num_rows != 0
  end

  public

  def show
    @photo = Photo.find(params[:id])

    if not photo_access
      flash[:error] = "This photo is private"
      @photo = nil
    end
  end

  def image
    @photo = Photo.find(params[:id])

    return if params[:style] != "ORIGINAL" and params[:style] != 'THUMB' and params[:style] != 'MEDIUM'
    if photo_access
      send_file (@photo.photo.path params[:size])
    else
      flash[:error] = "This photo is private"
      @photo = nil
    end
  end

  def create
    @photo = Photo.new(params[:photo])

    if @photo.save
      # Add to event
      join = EventPhoto.new
      join.photo_id = @photo.id
      join.event_id = params[:first_event]
      if join.save
        redirect_to :action => 'show', :id => @photo.id
      else
        flash[:error] = "Upload failed"
      end
    else
      flash[:error] = "Upload failed"
    end
  end

  def update
    @photo = Photo.find(params[:id])
    if @photo.save	
      redirect_to :action => 'show', :id => @photo.id
    else
      flash[:error] = "Unknown error"
    end
  end
end
