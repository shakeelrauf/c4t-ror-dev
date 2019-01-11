Rails.application.routes.draw do

  scope  controller: :send_form do
    get 	:login
    post 	:login, 													action: :login_user
    get 	:logout,													action: :logout
    get   :forget_pw
    post	:change_pw_save
    get		:invalid_key
		get		"/pw_init/:id/:key",							action: :pw_init
		get		"/pw_init/",							action: :pw_init
    post 	:forgot_pw, 											action: :forgot_reset
  end

  scope controller: :quotecars do
		get :quotescars
		get '/quotescar/:carNo',              action: :show
		post '/cars',         								action: :create_car
		get '/cars',         									action: :list_cars,         as: :carz
		get '/cars-select2',         					action: :search_cars
		get 'vehicles/count', 								action: :car_count
	end

  scope  controller: :dashboard do
    get 	:dashboard,												action: :dashboard
    get   :dispatch, 												action: :dispatched
  end

  root "dashboard#dashboard"

  scope  controller: :setting do
    get '/settings',                           action: :all
    post '/settings',                          action: :update
  end

  scope  controller: :charity do
    get '/charities',                           action: :get_charities
    get '/charities/add',              	 				action: :new
    get '/charities/:no',              	 				action: :edit
    post '/charities',                          action: :create
    get '/update',                     					action: :update
  end
  
  scope  controller: :heardofus do
    get '/heardofus',                           action: :get_heardsofus
    get '/heardofus/add',              	 				action: :new
    get '/heardofus/:no',              	 				action: :edit
    post '/heardofus',                          action: :create
    get '/update_hou',                     			action: :update
  end

	resources :users,param: :no, only: [:index, :edit,  :new, :create, :update] do
	  collection do
	    post '/blacklist/:no', 								action: :blacklist
	  end
  end
  scope controller: :booking do
    get '/quotes/:no/book', 								action: :book
    post '/booking', 												action: :booking
  end


	scope controller: :quote do
		post '/quotes',                          action: :create
		post '/quote',                           action: :create_quote
    get '/quotes/json',                      action: :quote_with_filter
		get '/status/json', 										 action: :status_json
    get '/vehicles/:no/json', 							 action: :vehicle_json
		get '/quotes/:id/edit',             	 	 action: :edit_quotes, 								as: :edit_quote
    get '/phone-numbers-select2', 					 action: :phone_list
    get '/vehicles-select2', 					       action: :vehicle_list
		post '/car-create',                      action: :create_car
    post '/car-remove',                      action: :remove_car
    get '/quotecar/:carNo',                  action: :retrive_car
		get '/render-vehicle-parameters', 			 action: :render_vehicle
		get '/car-price', 											 action: :car_price
		post '/car-price', 											 action: :car_price
		# get '/quotes',                           action: :get_quotes_by_filters
    patch '/quotes/:no',                     action: :quote
    post '/quote/:no/status',              	 action: :update_quote_status
    delete '/quotecar/:carNo',               action: :destroy
    get '/clients/:no/quotes',               action: :particular_customer_quotes
    get '/users/:no/quotes',                 action: :particular_customer_quotes_by_filters
    get '/status',                           action: :all_status
    get '/quotes',                       		 action: :all_quotes
    get '/create-quote',                     action: :create, 						 as: :create_quote
	end
	
  resources :customers
  scope controller: :customers do
    get '/customers/id/:no/json',             action: :get_customer
    get '/customers/:customerId/postal-select2', action: :postal_list
  end
  namespace :api do
		namespace :v1 do
			scope controller: :address do
				post 'clients/:no/address',          action: :client_address
				get  'clients/:no/address',          action: :address
				get  'address/:no/distance',         action: :distance
				get  'address/:no',                  action: :show
				post 'address-remove',               action: :destroy
				post 'address-create',               action: :create
      end

			scope  controller: :booking do
				post '/booking', 											 action: :update
      end

			resources :charities, :param => :no, :only => [:index,:create,:show,:update]

			scope controller: :contact do
				post "clients/:no/contact"	,        action: :contact
			end

      scope controller: :customer do
				get '/clients', action: :index
				post '/clients', action: :create
				get '/client/phones', action: :phones
				get "/clients/statistics/heardofus", action:  :heardofus
				get '/clients/:customerId/postal', action: :postal
        get '/clients/:no', action: :show
				patch '/clients/:no', action: :update
				get '/client/phones/:phone', action: :client_phones
			end

			scope controller: :distance do
				get  "/distance/:postal",            action: :distance
				post :distancediff,                  action: :distancediff
      end

      scope controller: :heardofus do
				post :heardsofus,                    action: :heardsofus
				get  :heardsofus,                    action: :get_heardsofus
				get  "/heardsofus/:no",              action: :show
				put  "/heardsofus/:no",              action:  :update
      end

			scope controller: :login do
				post :token,                         action: :token
				get  :token,                         action: :get_token
				delete 'token/:id', action: :destroy_session
      end

      scope controller: :qoutecars do
				get :quotescars
				get '/quotescar/:carNo',             action: :show
				get '/quotes/:quoteNo/cars',         action: :list
				get '/cars_count',         					 action: :list_cars_count
				get '/cars',         								 action: :list_cars
			end

			scope controller: :quick_quote do
				post '/quickquotes',             		 action: :save_quotes
				get '/quickquotes',         				 action: :index
			end

      scope controller: :quote do
				get '/quotes/json',                      action: :quote_with_filter
				get '/quotes',                           action: :get_quotes_by_filters
				get '/status',                           action: :all_status
				get '/all_quotes',                       action: :all_quotes
				post 'quotes',                           action: :create
				post '/create-car',                      action: :create_car
        post '/car-remove',                      action: :remove_car
        patch '/quotes/:no',                     action: :quote
        patch '/change_status',                  action: :update_status
        patch '/quotes/:no/status',              action: :update_quote_status
        delete '/quotecar/:carNo',               action: :destroy
				get '/quotes/:no',                     	 action: :show
				get '/clients/:no/quotes',               action: :particular_customer_quotes
				get '/users/:no/quotes',                 action: :particular_customer_quotes_by_filters
				get '/quotecar/:carNo',                  action: :retrive_car
    	end

			scope controller: :schedules do
				resources :schedules, :param => :no, :only => [:index,:create,:show,:destroy] 
			end

			scope controller: :sms do
				get :sms
				post 'sms/appreciations', 			   action: :appreciations
      end

			scope controller: :setting do
				get :settings
				put :settings,                       action: :update
				get 'settings/all', 								 action: :all
			end

      resources :users, :param => :no, :only => [:index,:create,:show,:update, :destroy] do
				patch :avatar
				collection do
					put ':no', action: :block_user
				end
      end

			scope controller: :vehicles do
				get :vehicles,							           action: :index
				post :vehicles,												 action: :create
				get 'vehicles/count', 								 action: :vehicle_count
				get "vehicles/:no",                    action: :show
			end

			scope controller: :voice do
				post '/voice/commingsoon',             action: :voice
			end
		end
	end
	post :test, controller: :api, action: :test
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end