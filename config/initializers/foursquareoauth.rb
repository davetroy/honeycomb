class FoursquareOauth
  
  CONSUMER_TOKEN = "G13C2EUPJHCZWFXK2YP1DZGHY4NLZCE3J2KJNTCDL3S3R0WX"
  CONSUMER_KEY = "AGBVZRBSM3GUAEQ4UZZV3WHDO3QCOWCM4WN1S1DA03AIZIYF"
  VENUE_ID = 131287
  
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
  
  def self.finish(request_token)
    final_request_token = OAuth::RequestToken.new(AUTH, request_token[:token], request_token[:secret])
    final_request_token.get_access_token
  end
  
  def check_in(fu)
    access_token = OAuth::AccessToken.new(API, fu.token, fu.secret)
    access_token.post("/v1/checkin?vid=#{VENUE_ID}&twitter=#{fu.update_twitter}")
  end
end