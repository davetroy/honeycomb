class OauthController < ApplicationController

  # Connect a particular user to foursquare
  def foursquare
    request_token = FoursquareOauth.get_request_token
    session[:person_id] = params[:person_id]
    session[:foursquare_token] = request_token
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
    puts "storing #{request_token.token} and #{request_token.secret}"
    person = Person.find(params[:person_id])
    tu = person.twitter_user || person.build_twitter_user
    tu.token = request_token.token
    tu.secret = request_token.secret
    tu.save
    redirect_to request_token.authorize_url
  end
  
  def setup_twitter
    person = TwitterOauth.finish(params[:oauth_token], params[:oauth_verifier])
    redirect_to person_path(person)
  end
  
end