class TwilioVoiceMessage
  require 'twilio-ruby'
  attr_reader :to, :url

  def initialize(to, url)
    @to, @url = to, url
  end

  def call
    @client = Twilio::REST::Client.new
    call = @client.calls.create(
      to: @to,
      from: ENV["TWILIO_PHONE_NUMBER"],
      url: @url)
  end
end