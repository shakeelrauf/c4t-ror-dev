class Api::V1::SchedulesController < ApiController
  before_action :authenticate_user
  include Api::V1::ScheduleMethods

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
    create_schedule
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
