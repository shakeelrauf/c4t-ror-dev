Rails.application.routes.draw do
	mount Ckeditor::Engine => '/ckeditor'
  root "dashboard#dashboard"

	resources :bookings, only: [:index] do
		member do
			get :quotes, action: :book
		end
  end

	resources :cars, controller: :quotecars, :only => [:index, :show, :create]
	get :car_search, controller: :quotecars, action: :search_cars
	resources :charities
	resources :customers

  scope controller: :customers do
		get '/customers/id/:no/json',             action: :get_customer
		get '/customers/:customerId/postal-select2', action: :postal_list
		get '/number_exist', action: :number_exist
  end

	scope  controller: :dashboard do
		get 	:dashboard
		get   :dispatched
	end

  scope controller: :distance do
		get  "/distance/:postal",            action: :distance, defaults: { format: 'json' }
		post :distancediff,                  action: :distancediff, defaults: { format: 'json' }
  end

  resources :heardofus
	resources :quotes do
		collection  do
			get :search
			get :status
			get :car_price
			get :phone_numbers
			post :car_price
			get :vehicle_search
			get :initialize_quote
		end
		member do
			post :create_car
			post :remove_car
			post :status, action: :update_status
		end
	end

  resources :quotecars, :only => [:index, :show]
	resources :settings, only: [:index, :update]

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

	resources :users,param: :no, only: [:index, :edit,  :new, :create, :update] do
		member do
			post :blacklist
		end
	end

	resources :vehicles, param: :no do
		member do
			get :show
			get :partial
		end
		collection do
			get :search
		end
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
				get  "/distance/:postal",            action: :distance,     defaults: { format: 'json' }
				post :distancediff,                  action: :distancediff, defaults: { format: 'json' }
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
