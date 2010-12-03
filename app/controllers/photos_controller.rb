class PhotosController < ApplicationController
  before_filter :login_required, :except => [:show, :eventshow]

  def new
    @photo = Photo.new
    @first_event = Event.find(params[:id])
  end

  def delete
    @photo = Photo.find(params[:id])
    if current_user.id == @photo.owner.id
      flash[:notice] = @photo.photo.original_filename + " deleted"
      @photo.destroy
      redirect_to :controller => 'users', :action => 'profile'
    else
      flash[:error] = 'You are not allowed to delete this image'
      redirect_to :action => 'show', :id => @photo.id
    end
  end

  def show
    @photo = Photo.find(params[:id])
  end

  private

  # Duplicates of the functions in event_controller

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

  public

  def create
    @photo = Photo.new(params[:photo])
    @photo.owner = current_user

    @event = Event.find(params[:first_event])
    return unless admin_check

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

  def eventshow
    @event = Event.find(params[:id])
  end
end
