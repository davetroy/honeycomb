class OauthController < ApplicationController

  # Connect a particular user to foursquare
  def foursquare
    request_token = FoursquareUser.get_request_token
    session[:person_id] = params[:person_id]    # TODO: this should be set by authentication
    session[:foursquare_token] = { :token => request_token.token, :secret => request_token.secret }
    redirect_to request_token.authorize_url
  end
  
  # Callback from foursquare oauth
  def setup_foursquare
    access_token = FoursquareUser.finish(session[:foursquare_token])
    person = Person.find(session[:person_id])
    fu = person.foursquare_user || person.build_foursquare_user
    fu.update_attributes(:token => access_token.token, :secret => access_token.secret)
    redirect_to person_path(person)
  end
  
  def twitter
    request_token = TwitterUser.get_request_token
    session[:person_id] = params[:person_id]    # TODO: this should be set by authentication
    session[:twitter_token] = { :token => request_token.token, :secret => request_token.secret }
    redirect_to request_token.authorize_url
  end
  
  def setup_twitter
    access_token = TwitterUser.finish(session[:twitter_token], params[:oauth_verifier])
    person = Person.find(session[:person_id])
    tu = person.twitter_user || person.build_twitter_user
    tu.update_attributes(:token => access_token.token, :secret => access_token.secret)
    user = tu.get_user
    tu.update_attribute(:username, user['screen_name'])
    redirect_to person_path(person)
  end
  
end