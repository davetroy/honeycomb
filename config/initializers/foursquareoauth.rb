class FoursquareOauth
  
  CONSUMER_TOKEN = "G13C2EUPJHCZWFXK2YP1DZGHY4NLZCE3J2KJNTCDL3S3R0WX"
  CONSUMER_KEY = "AGBVZRBSM3GUAEQ4UZZV3WHDO3QCOWCM4WN1S1DA03AIZIYF"

  AUTH = OAuth::Consumer.new(CONSUMER_TOKEN, CONSUMER_KEY, {
         :site               => "http://foursquare.com",
         :scheme             => :header,
         :http_method        => :post,
         :request_token_path => "/oauth/request_token",
         :access_token_path  => "/oauth/access_token",
         :authorize_path     => "/oauth/authorize"
        })
        
  API = OAuth::Consumer.new(CONSUMER_TOKEN, CONSUMER_KEY, {
         :site               => "http://api.foursquare.com",
         :scheme             => :header,
         :http_method        => :post
        })
    
  def self.get_request_token
    AUTH.get_request_token
  end
  
  def self.finish(oauth_token)
    fu = FoursquareUser.find_by_token(oauth_token)
    request_token = OAuth::RequestToken.new(AUTH, oauth_token, fu.secret)
    access_token=request_token.get_access_token
    fu.token = access_token.token
    fu.secret = access_token.secret
    fu.save
    fu.person
  end
end