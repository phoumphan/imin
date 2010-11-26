class HomeController < ApplicationController
  before_filter :login_required, :except => [:index, :about, :map]

  def index
  end

  def about
    
  end

  def map

  end

end
