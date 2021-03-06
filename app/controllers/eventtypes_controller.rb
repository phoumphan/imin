class EventtypesController < ApplicationController

  def new
    @eventtype = Eventtype.new
    @user_eventtypes = eventtype.user_eventtypes.new
    @event_eventtypes = eventtype.event_eventtypes.new    
  end

  #This action gets called to populate the autocomplete when an event administrator is adding an event tag to an event.
  #The action simply queries the database for whatever the user is typing, and renders a JSON object to be passed to the
  #autocomplete plugin
  def select_for_event
      
    	@eventtypes = Eventtype.find(:all, :conditions => [ 'LOWER(description) LIKE ?', '%' + params[:q].downcase + '%' ],  :order => 'description ASC', :limit => 8)
      
    	@eventtypes_hash = @eventtypes.collect! { |x| {"name" => x.description, "id" => x.id } }
      
      render :partial => "eventtypes/list_for_select"            
  end

  def eventtype_id

  end

  def destroy

  end

end
