ActionController::Routing::Routes.draw do |map|
  map.resources :payments, :collection => { :checkout => :post, :ipn => :post }, :member => { :confirm => :get, :complete => :post, :thanks => :get }
  
  map.root :controller => "appearances"
  map.resources :devices, :member => {:claim => :get, :assign => :post}

  map.logout '/logout', :controller => :people, :action => :logout
  map.confirm_login '/confirm_login/:id', :controller => :people, :action => :confirm_login, :conditions => {:method => :post}

  map.resources :people, :member => { :confirm_device_for => :get, :login => :get, :email_password => :get },
                         :collection => { :members => :get, :drop_ins => :get }
                         
  map.person_show 'people/:id/:type', :controller => 'people', :action => 'show'
    
  map.oauth_connect 'oauth/:action', :controller => 'oauth'
  map.fb_connect '/fb/:action', :controller => 'fb_connect'
  
end
