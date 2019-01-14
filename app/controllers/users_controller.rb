class UsersController < DashboardController
  before_action :login_required

  def index
    @users = JSON.parse ApiCall.get('/users', {}, headers).to_json
    render locals: {user: current_user, users: @users, isAdded: params[:isAdded], isEdited: params[:isEdited], statechanged: params[:statechanged]}
  end

  def edit
    @user = JSON.parse ApiCall.get('/users/'+params[:no],{}, headers).to_json
    render :form, locals: {user: current_user, user: @user}
  end

  def create
    params[:avatar] = ""
    params[:isSuperadmin] = "0"
    res = ApiCall.post("/users",JSON.parse(params.to_json), headers)
    return respond_error(res["error"]) if res["error"]
    return respond_ok
  end

  def update
    res = ApiCall.patch("/users/"+params[:no], JSON.parse(params.to_json), headers)
    return respond_error(res["error"]) if res["error"]
    return respond_ok
  end

  def blacklist
    res = ApiCall.put("/users/"+params[:no], JSON.parse(params.to_json), headers)
    return respond_error(res["error"]) if res["error"]
    return respond_ok
  end

  def new
    @user = User.new
    render :form, locals: {user: current_user, userData: @user}
  end
end
