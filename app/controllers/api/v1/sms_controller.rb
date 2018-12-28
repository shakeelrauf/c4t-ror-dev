class Api::V1::SmsController < ApiController
	before_action :authenticate_user , only: [:sms]

	def appreciations
		return render_json_response({:error => "You do not have authorization."}, :bad_request) if !params[:From] || !params[:Body]
		from = params[:From][2,10]
		note = params[:Body]
		client = Customer.where('phone = ? OR cellPhone = ? OR secondaryPhone = ?', from, from, from).first
		return render_json_response({:error => "You do not have authorization."}, :bad_request) if !client || !/^\d+$/.match(note) || note <= 0 || note > 10
		Satisfaction.create(idClient: client.id, from:  from,satisfaction: note)
		return render_json_response({:message => "Thank You!"}, :ok)
	end
	
	def sms
		sms = TwilioTextMessenger.new "This is a test", "4388241370"
		sms.call
		return render_json_response({:message => "ok"}, :ok)
	end
end
