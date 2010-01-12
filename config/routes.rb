ActionController::Routing::Routes.draw do |map|
  map.resources :payments, :collection => { :checkout => :post }, :member => { :confirm => :get, :complete => :post }

  map.root :controller => "appearances"
  map.resources :devices, :member => {:claim => :get, :assign => :post}
  map.resources :people, :collection => { :oauth_foursquare => :get }, :member => {:confirm_device_for => :get, :contact => :get }
  
  map.oauth_connect 'oauth/:action/:person_id', :controller => "oauth"
  map.oauth 'oauth/:action', :controller => "oauth"
end
