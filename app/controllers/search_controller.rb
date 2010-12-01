class SearchController < ApplicationController

  #render search/show.html.erb
  def show
    @results = Array.new()

    # Searching for the search word in the event title
    if params[:search]
      query = params[:search][:query]
      @searchfor = query


      #Advanced search option:  distance
      if params[:search][:distance] == "5km"
        @distance = 5
      elsif params[:search][:distance] == "10km"
        @distance = 10
      elsif params[:search][:distance] == "20km"
        @distance = 20
      elsif params[:search][:distance] == "50km"
        @distance = 50
      end

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
      if ( (@distance && @formality) != nil )
        #TODO:  1.  array1 = Using GeoKit, retrieve all the Events that are within @distance
        #2.  array2 = Array.new(Event.search_for_ids(query, :conditions => {:formality => @formality.to_s}))
        #3.  array3 = compare the two arrays, and only take the results that appear in both arrays!
      elsif ((@distance != nil) && (@formality == nil))
        #TODO:  need to calculate distance
      elsif ((@distance == nil) && (@formality != nil))
        ids = Array.new(Event.search_for_ids(query, :conditions => {:formality => @formality.to_s}))      
      else        
        ids = Array.new( Event.search_for_ids(query,:star => true) )
      end
      

      #Find the Event row/object associated with each event_id.
      #Add the Event row/object to the @results array
      for event in Event.find(ids)
        @results << event
      end     
           
		end

  end

  
  
end
