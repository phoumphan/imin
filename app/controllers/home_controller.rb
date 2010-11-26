class HomeController < ApplicationController
  def index
  end

  def about
    
  end

  def map

  end

  def closestmap
    @center = current_user.location
    respond_to do |form|
      form.html { render :map }
      form.xml { head :ok }
    end
  end

end
