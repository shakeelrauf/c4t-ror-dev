class ApplicationController < ActionController::Base
	skip_before_action :verify_authenticity_token
	include Response

	# protect_from_forgery prepend: true, with: :exception
end
