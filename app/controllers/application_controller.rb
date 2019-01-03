class ApplicationController < ActionController::Base
	skip_before_action :verify_authenticity_token
	include Response



	def headers
		{"Content-Type": "application/x-www-form-urlencoded","Authorization": get_token}
	end

	def login_required
		u = current_user
		if (!u.nil? && session[:token].present?)
			if (has_session? && is_session_expired?)
				end_session
				redirect_to login_path
				return false
			end
			logger.info("Auth successful")
			@p = u
			@pid = u.id.to_s
			set_session_expiration
			return true
		elsif (request.get?)
			session[:return_url] = request.url
		end

		logger.info("Auth NOT successful, sending to login")
		redirect_to login_path
		return false
	end

	def set_session_expiration
		session[:expires_at] = DateTime.now + 60.minutes
	end

	def is_session_expired?
		puts "======================> session[:expires_at], now: #{session[:expires_at]}, #{DateTime.now}"
		puts "======================> session[:expires_at], now: #{session[:expires_at].class}, #{DateTime.now.class}"
		(session[:expires_at].present? && session[:expires_at] < DateTime.now)
	end

	def end_session
		reset_session
		session[:user] = nil
		session[:user_id] = nil
		session[:return_url] = nil
		session[Constants::CSRF_TOKENS] = nil
		cookies[Constants::CSRF_COOKIE] = nil
		session[Constants::CSRF_HEADER] = nil
	end

	def successful_login(p, token)
		start_session p, token
		if (session[:return_url].present?)
			session[:redirect_url] = nil
			return
		end
	end


	def respond_ok(msg="ok")
		respond_to do |format|
			format.json { render json: {:message=>msg}.to_json }
		end
		true
	end

	def respond_res_msg res, msg
		respond_to do |format|
			format.json { render json: {:res=>res, :msg=>msg}.to_json }
		end
		true
	end

	def respond_error(msg="Error")
		respond_to do |format|
			format.json { render json: {:error=>msg}.to_json }
		end
		true
	end

	def respond_msg msg
		respond_to do |format|
			format.json { render json: {:message=>msg}.to_json }
		end
		true
	end

	def respond_res res
		respond_to do |format|
			format.json { render json: {:res=>res}.to_json }
		end
		true
	end

	def respond_json res
		respond_to do |format|
		  format.json {render json: res}
		end
	end

	def get_token
		if has_session? && is_session_expired?
			session[:token]["access_type"]+" "+session[:token]["access_token"]
		end
	end

	def start_session user, token
		ru = session[:return_url] if (session[:return_url].present?)
		reset_session
		session[:return_url] = ru
		session[:token] = token
		session[:user_id] = user["idUser"]
		session[Constants::CSRF_TOKENS] = []
		h = SecureRandom.hex(Constants::CSRF_SIZE)
		cookies[Constants::CSRF_COOKIE] = {
				:value => h,
				:expires => 1.day.from_now,
				:domain => request.domain
		}
		session[:user] = User.find_by_id(user["idUser"])
		session[Constants::CSRF_HEADER] = h
	end

	def has_session?
		session[:user].present?
	end

	def current_user
		User.find_by_id(session[:user_id])
	end

	def current_user_id
		session[:user_id]
	end

	def current_user_email
		(current_user.present? ? current_user.email : nil)
	end

	def current_username
		(current_user.present? ? current_user.username : nil)
	end
end
