class UsersController < DashboardController

  def index
    @users = JSON.parse ApiCall.get('/users', {}, headers).to_json
    render locals: {user: current_user, users: @users, isAdded: params[:isAdded], isEdited: params[:isEdited], statechanged: params[:statechanged]}
  end
end
