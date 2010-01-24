# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper

  before_filter :load_current_user

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5a060f6f83f7648101f0507d14582281'

  def load_current_user
    @user = Person.find(session[:person_id]) if session[:person_id]
  end

  def login_user(person)
    session[:person_id] = person.id
    @user = person
  end
  
  def logout_user
    session[:person_id] = nil
    session[:facebook_session] = nil
    @user = nil
  end  
  
  def authenticate(person)
    if params[:key]
      if params[:key] == person.temporary_key
        login_user(person)
      else
        logout_user
      end
    end
    
    if params[:person] && params[:person][:password]
      if Digest::MD5.hexdigest(params[:person][:password])==person.password_hash
        login_user(person)
      else
        logout_user
      end
    end      
  end
  
end
