class DashboardController < ApplicationController
  before_action :login_required
  include Customers

  def dashboard
    heardofus = Customer.customers_heardofus
    @count = Customer.count
    heardofus_required_format_data = []
    heardofus.each do |hou|
      heardofus_required_format_data.push [hou["type"],hou["count_heardsofus_type"]]
    end
    render locals: {heardofus: heardofus_required_format_data}
  end

  def dispatched
    cars = JSON.parse QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuote: params[:dispatch_id]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
    schedules = Schedule.all
    un_schedule_cars = list_unscheduled_cars(schedules, cars)
    render :dispatch , locals: {cars:  cars,unscheduledCars: un_schedule_cars}
  end



end