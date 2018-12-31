class Api::V1::SchedulesController < ApiController
  before_action :authenticate_user
  def index
    selected = JSON.parse(Schedule.includes([:car => [ :address, :information, :quote => [:customer, :dispatcher, :status ]] ]).to_json(include:
                              [car: 
                                { include: 
                                  [ :address, :information, 
                                    {quote: 
                                      { include: 
                                        [ :customer, :dispatcher, :status]
                                      }
                                    } 
                                  ]
                                } 
                              ]))
    render json: selected, status: :ok, adapter: :json_api
  end

  def show
    selected = Schedule.includes(:car).where(idCar: params[:no]).first.to_json(include: :car)
    return render_json_response({:error => CAR_NOT_FOUND, :success => false}, :not_found) if !selected.present?
    render json: selected, status: :ok, adapter: :json_api
  end

  def create
    if invalid_params
      return render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    else
      quoteCar = QuoteCar.where(idQuoteCars: params[:idCar]).first
      if !quoteCar.present?
        return render_json_response({:error => CAR_NOT_FOUND, :success => false}, :not_found)
      else 
        params[:dtEnd] = nil if params[:dtEnd].eql?("")
        sched = Schedule.where(idCar: params[:idCar]).first
        if !sched.present?
          newOne = Schedule.new(idCar: params[:idCar],truck: params[:truck],dtStart: params[:dtStart],dtEnd: params[:dtEnd]).save!
          return render_json_response(newOne, :ok)
        else
          sched.update(truck: params[:truck],dtStart: params[:dtStart],dtEnd: params[:dtEnd])
          return render_json_response(sched, :ok)
        end
      end
    end
  end

  def destroy
    Schedule.where(idCar: params[:no]).destroy_all
    return render_json_response({:message => SCHEDULE_DELETED, :success => true}, :ok)
  end

  private
  def invalid_params
    !params[:idCar] || !params[:truck] || !params[:dtStart]
  end
	
end
