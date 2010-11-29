class FriendshipsController < ApplicationController
  before_filter :login_required
    
  #Once a User A clicks on a "Request Friend" link for User B, a notification should appear
  #to User B on his profile page.  See the pending_friend_requests controller.
  #Next to the notification on User B's profile page, a "Confirm Friend" link will appear
  #calling this action.

  #This action creates two rows in the Friendships table, and also removes
  #the appropriate row from the Pending_Friend_Requests table.
  def create
    @friendship_a = current_user.friendships.build(:friend_id => params[:friend_id])
    
    @other_user = User.find(params[:friend_id])
    @friendship_b = @other_user.friendships.build(:friend_id => current_user.id)

    @pending_friend_request = PendingFriendRequest.find(:first, :conditions => ["user_id = ? AND requester_id = ?", current_user.id, params[:friend_id]])
    
    
    if (@friendship_a.save && @friendship_b.save && @pending_friend_request.destroy)
      flash[:notice] = "Friend Added!"
      redirect_to profile_page_path
    else
      flash[:error] = "Problems adding friend"
      redirect_to profile_page_path
    end
  end

  #render search/show_users.html.erb
  def display
    @results = Array.new()
    @user = current_user
    
    # Searching for an existing user's name or login
    if params[:search]
      query = params[:search][:query]
      @searchfor = query

      #Create an 'ids' array that will contain all the User ids that are returned from the search query
      #This method is from the Thinking-Sphinx plugin
      ids = Array.new( User.search_for_ids(query,:star => true) )

      #Find the User row/object associated with each user_id.
      #Add the User row/object to the @results array
      for user in User.find(ids)
        @results << user
      end
    end
  end

  def destroy
    
  end
end
