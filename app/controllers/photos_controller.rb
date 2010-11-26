class PhotosController < ApplicationController
  before_filter :login_required, :except => [:show]

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

  def create
    @photo = Photo.new(params[:photo])
    @photo.owner = current_user

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
end
