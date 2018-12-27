Rails.application.routes.draw do
	namespace :api do
		namespace :v1 do
			resources :users, :param => :no, :only => [:index,:create,:show,:update, :destroy] do 
				patch :block_user
				patch :avatar
			end
			scope controller: :contact do
				post "clients/:no/contact"	, action: :contact
			end

			scope controller: :login do
				post :token, action: :token
				get :token, action: :get_token
				delete 'token/:id', action: :destroy_session
			end
			post :booking, controller: :booking, action: :update
			resources :charities, :param => :no, :only => [:index,:create,:show,:update]

			scope controller: :distance do 
				get "/distance/:postal", action: :distance
				post :distancediff, action: :distancediff
			end
			scope controller: :heardofus do 
				post :heardsofus, action: :heardsofus
				get :heardsofus, action: :get_heardsofus
				get "/heardsofus/:no", action: :show
				put "/heardsofus/:no", action:  :update
			end
			scope controller: :customer do 
				resources :clients, :param => :no, :only => [:index, :create, :show, :update]
				get 'client/phones', action: :phones
				get 'client/phones/:phone', action: :client_phones
				get "/clients/statistics/heardofus", action:  :heardofus
				get '/clients/:customerId/postal', action: :postal
			end
		end
	end
	post :test, controller: :api, action: :test

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end