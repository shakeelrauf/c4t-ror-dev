# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
require File.expand_path(File.dirname(__FILE__) + "/environment")

every '00 */5 * * * *' do
	schedules = Schedule.where(dtStart: (Time.now+1.hour).strftime("%Y-%m-%d %H:%M:00"))
	if schedules.count > 0 
		r_clients = []
    schedules.each do |r_schedule|
      exist = r_clients.map {|r_client| r_client.id == r_schedule.car.quote.customer.id }
      r_clients.push(r_schedule.car.quote.customer) if !exist 
    end

    r_clients.each do |r_client|
    	voice = TwilioVoiceMessage.new r_client.phone, "http://admin.cashfortrashcanada.com:8181/api/v1/voice/commingsoon"
      voice.call
    end
  end
end