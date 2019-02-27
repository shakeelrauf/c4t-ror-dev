module Api::V1::ScheduleMethods
  def create_schedule
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


  private
  def invalid_params
    !params[:idCar] || !params[:truck] || !params[:dtStart]
  end

end