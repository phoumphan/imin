class EventtypesController < ApplicationController

  def new
    @eventtype = Eventtype.new
    @user_eventtypes = eventtype.user_eventtypes.new
    @event_eventtypes = eventtype.event_eventtypes.new    
  end

  
  def select_for_event
      
    	@eventtypes = Eventtype.find(:all, :conditions => [ 'LOWER(description) LIKE ?', '%' + params[:q].downcase + '%' ],  :order => 'description ASC', :limit => 8)
      
    	@eventtypes_hash = @eventtypes.collect! { |x| {"name" => x.description, "id" => x.id } }
      
      render :partial => "eventtypes/list_for_select"
      
      
  end

end
