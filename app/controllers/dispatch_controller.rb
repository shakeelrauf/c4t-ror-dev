class DispatchController < ApplicationController
  before_action :login_required
  include Customers
  include Api::V1::ScheduleMethods

  def quote
    if params[:truck_id].present?
      schedules = JSON.parse Schedule.includes([:car => [:information, :address, :quote => [:customer,:dispatcher, :status]]]).where(truck: params[:truck_id]).to_json(include: [{car: {include: [:information,:address, {quote: {include: [:customer,:dispatcher,:status]}}]}}])
      @schedules = format_schedule_cars(schedules)
      return render_json_response(@schedules, :ok)
    end
    cars = JSON.parse QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuote: params[:no]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
    schedules = JSON.parse Schedule.includes([:car => [:information, :address, :quote => [:customer,:dispatcher, :status]]]).all.to_json(include: [{car: {include: [:information,:address, {quote: {include: [:customer,:dispatcher,:status]}}]}}])
    @schedules = format_schedule_cars(schedules)
    @unschedule_cars = list_quote_cars(cars)
    @trucks =  Truck.select("id, name AS title").all.order('name ASC')
  end

  def create
    create_schedule
  end

  def schedules
    schedules = JSON.parse Schedule.includes([:car => [:information, :address, :quote => [:customer,:dispatcher, :status]]]).all.to_json(include: [{car: {include: [:information,:address, {quote: {include: [:customer,:dispatcher,:status]}}]}}])
    @schedules = format_schedule_cars(schedules)
    return render_json_response(@schedules, :ok)
  end

  def destroy
    sched = Schedule.where({idCar: params[:idCar]})
    sched.destroy_all
    render_json_response(sched, :ok)
  end

  def unsched
    car = JSON.parse QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuoteCars: params[:carId]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
    render partial: 'dashboard/unsched_car',locals: {car: car[0]}
  end

  def format_schedule_cars(schedules)
    formated = []
    schedules.each do |schedule|
      address = schedule['car']['address']['address'] + " " + schedule['car']['address']['city'] + " " + schedule['car']['address']['postal'] + " " + schedule['car']['address']['province']
      mmy = schedule['car']['information']['make'] + " " + schedule['car']['information']['model'] + " " + schedule['car']['information']['year']
      temp = {
          id: schedule['car']['idQuoteCars'],
          title: mmy + "<br>" + address,
          start: schedule['dtStart'].to_datetime.strftime("%Y-%m-%dT%H:%M:%S"),
          end: schedule['dtStart'].to_datetime.strftime("%Y-%m-%dT%H:%M:%S"),
          resourceId: schedule['truck'],
          description: "<div onclick='closepopup();' class='close-popup'><i class='icofont icofont-close-squared-alt'></i></div><iframe src='https://www.google.com/maps?q=" + URI.encode(address) + "&output=embed&z=12' width='600' height='400'></iframe>",
          information: schedule['car'],
          address: address,
          distance: schedule['car']['distance'],
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
