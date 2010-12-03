class SearchController < ApplicationController

  #render search/show.html.erb
  def show
    @results = Array.new()

    # Searching for the search word in the event title
    if params[:search]
      query = params[:search][:query]
      @searchfor = query
      
      #Advanced search option:  formality
      if (params[:search][:formality] == "Formal")
        @formality = "Formal"
      elsif (params[:search][:formality] == "Dressy")
        @formality = "Dressy"        
      elsif (params[:search][:formality] == "Dressy-Casual")
        @formality = "Dressy-Casual"
      elsif (params[:search][:formality] == "Casual")
        @formality = "Casual"
      end

      #Create an 'ids' array that will contain all the Event ids that are returned from the search query
      #The search_for_ids method is from the Thinking-Sphinx plugin
      if (@formality != nil)
        ids = Array.new(Event.search_for_ids(query, :conditions => {:formality => @formality.to_s}))      
      else        
        ids = Array.new( Event.search_for_ids(query,:star => true) )
      end
      

      #Find the Event row/object associated with each event_id.
      #Add the Event row/object to the @results array
      if !params[:search][:cost].blank?
        @cost = params[:search][:cost].to_i        
      end

      for event in Event.find(ids)
        if (@cost != nil)
          if (@cost <= event.cost)
            @results << event
          end
        else
          @results << event
        end                        
      end     
           
		end

  end

  
  
end
