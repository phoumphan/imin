class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  

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

  #render users/profile
  def profile
    @user = current_user       

    #Information for Event Calendar
    time = Time.new
    @month = time.month
    @year = time.year
    @shown_month = Date.civil(@year, @month)
    # To restrict what events are included in the result you can pass additional find options like this:
    #
    # @event_strips = Event.event_strips_for_month(@shown_month, :include => :some_relation, :conditions => 'some_relations.some_column = true')
    
    @event_strips = Event.event_strips_for_month(@shown_month)

    
  end

  #render users/edit_info
  def edit_info
    if current_user
      @user = current_user
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
  def update
    @user = current_user
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "Profile Successfully Updated"
      redirect_to :action => 'profile'
    else
      render :action => 'preferences', :id => params[:id]
    end
  end

  #method used to change user password.  Called from users/preferences.html.erb page when
  #"change password" link is clicked
  def change_password

  end

  def show
    @user = User.find(params[:id])

    #If a user tries to view himself, it will redirect to his profile page
    if (@user.id == current_user.id)
      redirect_to (profile_page_path)
    end
    
  end
end
