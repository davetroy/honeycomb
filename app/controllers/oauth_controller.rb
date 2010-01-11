class OauthController < ApplicationController

  # Connect a particular user to foursquare
  def foursquare
    request_token = FoursquareOauth.get_request_token
    session[:person_id] = params[:person_id]
    session[:foursquare_token] = { :token => request_token.token, :secret => request_token.secret }
    redirect_to request_token.authorize_url
  end
  
  # Callback from foursquare oauth
  def setup_foursquare
    access_token = FoursquareOauth.finish(session[:foursquare_token])
    person = Person.find(session[:person_id])
    fu = person.foursquare_user || person.build_foursquare_user
    fu.update_attributes(:token => access_token.token, :secret => access_token.secret)
    redirect_to person_path(person)
  end
  
  def twitter
    request_token = TwitterOauth.get_request_token
    session[:person_id] = params[:person_id]
    session[:twitter_token] = { :token => request_token.token, :secret => request_token.secret }
    redirect_to request_token.authorize_url
  end
  
  def setup_twitter
    access_token = TwitterOauth.finish(session[:twitter_token], params[:oauth_verifier])
    person = Person.find(session[:person_id])
    tu = person.twitter_user || person.build_twitter_user
    tu.update_attributes(:token => access_token.token, :secret => access_token.secret)
    logger.info access_token.get('show/user').body
    #screen_name = access_token.get('show/user').body[:user][:screen_name]
    #tu.update_attribute(:user, screen_name)
    redirect_to person_path(person)
  end
  
end