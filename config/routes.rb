Rails.application.routes.draw do
	namespace :api do
		namespace :v1 do
			resources :users, :param => :no, :only => [:index,:create,:show,:update, :destroy] do 
				patch :avatar
			end
			scope controller: :login do
				post :token, action: :token
				get :token, action: :get_token
				delete 'token/:id', action: :destroy_session
			end
			post :booking, controller: :booking, action: :update
			resources :charities, :param => :no, :only => [:index,:create,:show,:update]
		end
	end
	post :test, controller: :api, action: :test

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
