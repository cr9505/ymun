Site::Application.routes.draw do

  ActiveAdmin.routes(self)

  resource :delegation do
    get 'change_payment_type/:payment_type' => 'delegations#change_payment_type', as: :change_payment_type
    get 'change_payment_currency' => 'delegations#change_payment_currency'
    get 'edit/:step' => 'delegations#edit', as: :edit_page
    put 'update/:step' => 'delegations#update', as: :update_page
    resources :payments do
      get 'execute' => 'payments#execute_payment', as: :execute, on: :collection
    end
    resources :delegates do
      
    end
    resources :seats
  end

  # get 'delegation' => 'delegations#index', as: :delegation

  devise_for :users, :controllers => { :sessions => 'sessions', :confirmations => 'confirmations' }, :skip => :registrations
  devise_for :advisors, :controllers => { :registrations => 'advisor_registrations', :confirmations => 'confirmations' }, :skip => :sessions
  devise_for :delegates, :controllers => { :registrations => 'delegate_registrations', :confirmations => 'confirmations' }, :skip => :sessions
  devise_for :admin_users, :controllers => { :registrations => 'admin_registrations', :confirmations => 'confirmations' }, :skip => :sessions

  get 'privacy' => 'home#privacy_policy', as: :privacy_policy

  root :to => "home#index"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
