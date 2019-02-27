class DispatchController < ApplicationController
  before_action :login_required
  include Customers
  include Api::V1::ScheduleMethods

  def quote
    cars = JSON.parse QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuote: params[:dispatch_id]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
    schedules = Schedule.all
    @schedules = format_schedule_cars(schedules)
    @unschedule_cars = list_quote_cars(cars)
  end

  def create
    create_schedule
  end

  def delete
    sched = Schedule.where({idCar: params[:no]})
    sched.destroy_all
  end

  def format_schedule_cars(schedules)
    formated = []
    schedules.each do |schedule|
      address = schedule.car.address.address + " " + schedule.car.address.city + " " + schedule.car.address.postal + " " + schedule.car.address.province
      mmy = schedule.car.information.make + " " + schedule.car.information.model + " " + schedule.car.information.year
      temp = {
          id: schedule.car.id,
          title: mmy + "<br>" + address,
          start: schedule.dtStart.strftime("%Y-%m-%dT%H:%M:%S"),
          end: schedule.dtStart.strftime("%Y-%m-%dT%H:%M:%S"),
          resourceId: schedule.truck,
          description: "<div onclick='closepopup();' class='close-popup'><i class='icofont icofont-close-squared-alt'></i></div><iframe src='https://www.google.com/maps?q=" + URI.encode(address) + "&output=embed&z=12' width='600' height='400'></iframe>",
          information: schedule.car,
          address: address,
          distance: schedule.car.distance,
          mmy: mmy
      }
      if (temp['end'] == "Invalid date")
        temp['end'] = nil
      end
      formated.push(temp)
    end
    return formated
  end

  def list_quote_cars(cars)
    quoteCars = {}
    cars.each do |car|
      quoteCars[car['idQuoteCars']] = car
    end
    return quoteCars
  end
end
