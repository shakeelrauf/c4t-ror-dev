Rails.application.routes.draw do
	namespace :api do
		namespace :v1 do
			resources :users, :param => :no, :only => [:index,:create,:show,:update, :destroy] do 
				patch :avatar
			end
			get "booking" => "booking#create"
			scope controller: :login do
				post :token, action: :token
				get :token, action: :get_token
				delete 'token/:id', action: :destroy_session
			end
		end
	end
	post :test, controller: :api, action: :test

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
