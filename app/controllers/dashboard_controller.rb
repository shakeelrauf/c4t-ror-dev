class DashboardController < ApplicationController
  before_action :login_required
  include Customers

  def dashboard
    heardofus = get_heard_of_us
    countClients =  heardofus.count
    render locals: {user: current_user,heardofus: heardofus, countClients: countClients}
  end

  def dispatched
    cars =  QuoteCar.includes([:quote => [ :status]])
    schedules = Schedule.all
    un_schedule_cars = list_unscheduled_cars(schedules, cars)
    render :dispatch , locals: {cars:  cars,unscheduledCars: un_schedule_cars}
  end


  private
  def list_unscheduled_cars(schedules, cars)
    un_scheduled_cars = {}
    return un_scheduled_cars if !(cars.present?)
    return un_scheduled_cars if !(schedules.present?)
    if cars && cars.length
      cars.each do |car|
        found = false
        if !(schedules.is_a? Array)
          schedules.each do |schedule|
            if car && car.idQuoteCars == schedule.idCar
              found =  true
            end
          end
        end
        if !found && car.quote.status.name=="Accepted"
          un_scheduled_cars[car.id] = car
        end
      end
    end
    un_scheduled_cars
  end
end