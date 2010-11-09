class SearchController < ApplicationController

  #render search/show.html.erb
  def show
    @results = Array.new()

    # Searching for the search word in the event title
    if params[:search]
      query = params[:search][:query]
      @searchfor = query

      #Create an 'ids' array that will contain all the Event ids that are returned from the search query
      #This method is from the Thinking-Sphinx plugin
      ids = Array.new( Event.search_for_ids(query,:star => true) )

      #Find the Event row/object associated with each event_id.
      #Add the Event row/object to the @results array
      for event in Event.find(ids)
        @results << event
      end     
           
		end

  end

end
