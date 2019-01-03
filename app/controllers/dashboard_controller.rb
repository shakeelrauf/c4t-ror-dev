class DashboardController < ApplicationController
  before_action :login_required

  def dashboard

  end

  def dispatched
    cars = ApiCall.get("/quotescars",{}, headers)
    @schedules = ApiCall.get("/schedules", {}, headers)
    un_schedule_cars = list_unscheduled_cars(@schedules, cars)
    render :dispatch , locals: {cars:  cars,unscheduledCars: un_schedule_cars}
  end


  def list_unscheduled_cars(schedules, cars)
    un_scheduled_cars = {}
    if cars && cars.length
      cars.each do |car|
        found = false
        schedules.each do |schedule|
          if car["id"] == schedule["idCar"]
            found =  true
          end
        end
        if !found && car["quote"]["status"]["name"]=="Accepted"
          un_scheduled_cars[car["id"]] = car
        end
      end
    end
    un_scheduled_cars
  end
end
