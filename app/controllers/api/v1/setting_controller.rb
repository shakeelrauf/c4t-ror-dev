class Api::V1::SettingController < ApiController
	before_action :authenticate_user
	before_action :authenticate_admin, only: [:all, :update]
	def settings
		last_settings = Setting.where("dtCreated IN (SELECT MAX(dtCreated) FROM Settings GROUP BY name)")
		return render_json_response(last_settings, :ok)
	end

	def all
		settings = Setting.all
		return render_json_response(settings, :ok)
	end

	def update
		j = 0
		l = params[:settings].length
		params[:settings].each do |setting|
			Setting.where(name: setting[:name], grade: setting[:grade])
				.update_all(name: setting[:name],	label: setting[:name],
				value: setting[:value],
				grade: setting[:grade])
				j+=1
		end
		return render_json_response({message: SETTING_UPDATE_MSG}, :ok) if (j >= l)
	end
end
