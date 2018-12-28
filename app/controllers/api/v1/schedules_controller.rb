class Api::V1::SchedulesController < ApiController
  before_action :authenticate_user
  def index
    selected = Schedule.includes([:car => [ :address, :information, :quote => [:customer, :dispatcher, :status ]] ]).to_json(include: 
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
                              ])
    render json: selected, status: :ok, adapter: :json_api
  end

  def show
    selected = Schedule.includes(:car).where(idCar: params[:no]).first.to_json(include: :car)
    if !selected.present?
      return render_json_response({:error => CAR_NOT_FOUND, :success => false}, :not_found)
    else
      render json: selected, status: :ok, adapter: :json_api
    end
  end

  def create
    if invalid_params
      return render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    else
      #Check if id car exist.
      quoteCar = QuoteCar.where(idQuoteCars: params[:idCar]).first
      if !quoteCar.present?
        return render_json_response({:error => CAR_NOT_FOUND, :success => false}, :not_found)        
      else 
        if params[:dtEnd].eql?("")
          params[:dtEnd] = nil
        end
        #Check if we insert or update.
        sched = Schedule.where(idCar: params[:idCar]).first
        if !sched.present?
          #Insert
          newOne = Schedule.new(
              idCar: params[:idCar],
              truck: params[:truck],
              dtStart: params[:dtStart],
              dtEnd: params[:dtEnd])
          return render_json_response(newOne, :ok) if newOne.save
          return render_json_response({:error => PROBLEM_OCCURRED, :success => false}, :not_found)
        else
          #Update

          newOne = Schedule.where(idCar: params[:idCar]).first
          if newOne.update({
              truck: params[:truck],
              dtStart: params[:dtStart],
              dtEnd: params[:dtEnd]
            })
            return render_json_response(newOne, :ok)
          else
            return render_json_response({:error => PROBLEM_OCCURRED, :success => false}, :not_found)
          end
        end
      end
    end
  end

  def destroy
    results = Schedule.where(idCar: params[:no]).destroy
    return render_json_response({:message => SCHEDULE_DELETED, :success => true}, :ok)
  end

  private
  def invalid_params
    !params[:idCar] || !params[:truck] || !params[:dtStart]
  end
	
end
