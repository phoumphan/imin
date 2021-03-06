ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.change_password '/change_password', :controller => 'users', :action => 'change_password'
  map.eventtypes_autocomplete 'eventtypes/select_for_event', :controller => 'eventtypes', :action => 'select_for_event'
  map.edit_info_page 'users/edit_info', :controller => 'users', :action => 'edit_info'
  map.show 'events/show/:id', :controller => 'events', :action => 'show'
  map.profile_page 'users/profile', :controller => 'users', :action => 'profile'
  map.closestevents_page 'users/closestevents', :controller => 'users', :action => 'closestevents'
  map.preferences_page 'users/preferences', :controller => 'users', :action => 'preferences'  
  map.edit_info_page 'users/edit_info', :controller => 'users', :action => 'edit_info'
  map.save_preferences 'users/update', :controller => 'users', :action => 'update'
  map.save_info 'users/info', :controller => 'users', :action => 'info'
  map.edit_event 'events/edit/:id', :controller => 'events', :action => 'edit'
  map.events_page 'users/events', :controller => 'users', :action => 'events'
  map.save_event 'events/create', :controller => 'events', :action => 'create'
  map.calendar '/calendar/:year/:month', :controller => 'calendar', :action => 'index', :requirements => {:year => /\d{4}/, :month => /\d{1,2}/}, :year => nil, :month => nil
  map.resources :users, :member => { :suspend => :put,
                                        :unsuspend => :put,
                                        :purge => :delete }
  map.resources :events
  map.resource :session
  map.resource :eventtypes
  map.resource :search
  map.resource :photos
  map.resource :friendships
  map.resource :pending_friend_requests

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
