class PendingFriendRequestsController < ApplicationController

  #This will be called when an "Request Friendship" link is clicked
  #As users are not friend immediately after a request, we need to store the pending friend requests somewhere
  #This action will just create a new row in the PendingFriendRequests table
  def create

    @user = User.find(params[:user_id])    
    @pending_friend_request = @user.pending_friend_requests.build(:requester_id => current_user.id)
    
    if (@pending_friend_request.save )
      flash[:notice] = "Friendship Requested!"
      redirect_to root_url
    else
      flash[:error] = "Problems requesting friendship"
      redirect_to root_url
    end
  end

  def destroy
    
  end

  
end
