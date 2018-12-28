Rails.application.routes.draw do
	namespace :api do
		namespace :v1 do
			resources :users, :param => :no, :only => [:index,:create,:show,:update, :destroy] do 
				patch :block_user
				patch :avatar
			end
			scope controller: :contact do
				post "clients/:no/contact"	,        action: :contact
			end

			scope controller: :login do
				post :token,                         action: :token
				get  :token,                         action: :get_token
				delete 'token/:id', action: :destroy_session
			end
			post :booking, controller: :booking,   action: :update
			resources :charities, :param => :no, :only => [:index,:create,:show,:update]

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

			scope controller: :address do
				post 'clients/:no/address',          action: :client_address
				get  'clients/:no/address',          action: :address
				get  'address/:no/distance',         action: :distance
				get  'address/:no',                  action: :show
				post 'address-remove',               action: :destroy
				post 'address-create',               action: :create
			end

			scope controller: :qoutecars do
				get :quotescars
				get '/quotescar/:carNo',             action: :show
				get '/quotes/:quoteNo/cars',         action: :list  
			end
			scope controller: :customer do 
				get '/clients', action: :index
				post '/clients', action: :create
				get '/clients/:no', action: :show
				patch '/clients/:no', action: :update
				get '/client/phones', action: :phones
				get '/client/phones/:phone', action: :client_phones
				get "/clients/statistics/heardofus", action:  :heardofus
				get '/clients/:customerId/postal', action: :postal
			end
			scope controller: :setting do
				get :settings
				put :settings,                       action: :update
				get 'settings/all', 								 action: :all
			end

			scope controller: :schedules do
				resources :schedules, :param => :no, :only => [:index,:create,:show,:destroy] 
			end
		end
	end
	post :test, controller: :api, action: :test

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end