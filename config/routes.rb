ActionController::Routing::Routes.draw do |map|
  map.resources :payments, :collection => { :checkout => :post }, :member => { :confirm => :get, :complete => :post }

  map.root :controller => "appearances"
  map.resources :devices, :member => {:claim => :get, :assign => :post}
  map.resources :people, :collection => { :oauth_foursquare => :get },
                         :member => {:confirm_device_for => :get, :foursquare => :get, :activity => :get, :devices => :get }  
end
