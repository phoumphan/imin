class PhotosController < ApplicationController
  before_filter :login_required, :except => [:show]

  def new
    @photo = Photo.new
    @first_event = Event.find(params[:id])
  end

  def edit
    @photo = Photo.find(params[:id])
  end

  def show
    @photo = Photo.find(params[:id])
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
    @photo = params[:photo]
    if @photo.save
      redirect_to :action => 'show', :id => @photo.id
    else
      flash[:error] = "Unknown error"
    end
  end
end
