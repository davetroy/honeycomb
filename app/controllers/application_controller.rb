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
  
  def logout_user
    session[:person_id] = nil
    session[:facebook_session] = nil
  end
  
  def authenticate_person
    if params[:key]
      if params[:key] == @person.temporary_key
        session[:person_id] = @person.id
        load_current_user
      else
        session[:person_id] = nil
        render :status => 404
      end
    end
    
    if params[:person] && params[:person][:password]
      if Digest::MD5.hexdigest(params[:person][:password])==@person.password_hash
        session[:person_id] = @person.id
      else
        session[:person_id] = nil
      end
    end      
  end
  
end
