MapsqueakProto::Application.routes.draw do
  get "squeak_check/new"

  get "squeak_check/create"

  get "squeak_check/update"

  get "squeak_check/edit"

  get "squeak_check/destroy"

  get "squeak_check/index"

  get "squeak_check/show"

  resources :share_requests, :except => [:edit, :destroy]
  resources :squeak_checks, :except => [:destroy]

  get "sessions/new"
  get "users/new"
 
  resources :squeaks
  get "squeaks/new"
  match 'squeaks/map_preview/:id', :to => 'squeaks#map_preview'
  match 'squeaks/image/:id', :to => 'squeaks#squeak_image'
  match 'squeaks/map_image/:id', :to => 'squeaks#map_image'
  match "squeak_search", :to => 'squeaks#search'

  match '/index', :to => 'squeaks#index'
  match '/mobile', :to => 'pages#mobile_app'
  match '/news',    :to => 'pages#news'
  match '/about',    :to => 'pages#about'
  match '/terms',    :to => 'pages#terms'
  match '/contact',    :to => 'pages#contact'
  match '/admin', :to => 'pages#admin'

  # root :to => 'squeaks#index'
  root :to => 'squeaks#proper_home'

  resources :users
  get "user_search", :to => "users#search"

  resources :sessions, :only => [:new, :create, :destroy]

  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  match '/signout/:provider', :to => 'sessions#destroy'
  
  get   '/login', :to => 'sessions#new', :as => :login
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure', :to => 'sessions#failure'
  #The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
