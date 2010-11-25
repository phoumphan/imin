class CalendarController < ApplicationController
  
  def index
    @month = params[:month].to_i
    @year = params[:year].to_i

    @shown_month = Date.civil(@year, @month)

    # To restrict what events are included in the result you can pass additional find options like this:
      #
      # @event_strips = Event.event_strips_for_month(@shown_month, :include => :some_relation, :conditions => 'some_relations.some_column = true')
      #

    @event_strips = Event.event_strips_for_month(@shown_month)
  end
  
end