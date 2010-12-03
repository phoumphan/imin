# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include AuthenticatedSystem

  #Session expiry code taken from http://blog.tmisoft.com/2009/09/restful-authentication-session-timeout.html
  before_filter :session_expiry, :except => [:login, :logout]
  before_filter :update_activity_time, :except => [:login, :logout]

  #Session expiry code taken from http://blog.tmisoft.com/2009/09/restful-authentication-session-timeout.html
  def session_expiry
    unless session[:expires_at].nil?
      @time_left = (session[:expires_at] - Time.now).to_i
      unless @time_left > 0
        logout_killing_session!
        flash[:error] = 'Your session expired. Please, login again.'
        redirect_to login_url
      end
    end
  end

  #Session expiry code taken from http://blog.tmisoft.com/2009/09/restful-authentication-session-timeout.html 
  def update_activity_time
    session[:expires_at] = 15.minutes.from_now
  end


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
