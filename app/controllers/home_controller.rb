class HomeController < ApplicationController
  def index

  end

  def about
    if current_user
      redirect_to (profile_page_path)
    end
  end

  def map

  end

end
