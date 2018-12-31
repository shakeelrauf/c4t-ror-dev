class Api::V1::VoiceConroller < ApiController
	require 'twilio-ruby'

	def voice
		response = Twilio::TwiML::VoiceResponse.new
		response.pause(length: 2)
		response.say(voice: 'alice', message: 'Hello. This is Cash For Trash. We want to inform you that we will be at your home in 60 minutes. Thanks to you and see you soon.')
		response.hangup
		render xml: resource, status: 200, content_type: Mime::XML
	end
end