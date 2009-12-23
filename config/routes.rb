ActionController::Routing::Routes.draw do |map|
  map.resources :payments, :collection => { :checkout => :post }, :member => { :confirm => :get, :complete => :post }

  map.root :controller => "appearances"
  map.resources :devices, :member => {:claim => :get, :assign => :post}
  map.resources :people, :member => {:confirm_device_for => :get}
  
end
