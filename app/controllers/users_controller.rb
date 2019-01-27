class UsersController < DashboardController
  include Users
  before_action :login_required

  def index
    @users = User.all
    render locals: {user: current_user, users: @users, isAdded: params[:isAdded], isEdited: params[:isEdited], statechanged: params[:statechanged]}
  end

  def edit
    @user = User.find_by_id(params[:no])
    render :form, locals: {user: @user}
  end

  def create
    params[:avatar] = ""
    params[:isSuperadmin] = "0"
    create_user(current_user, params)
    flash[:success] = 'User is successfully Created!'
  end

  def update
    update_user
  end

  def blacklist
    return respond_json({:error => "You are not allowed to change state of this user."}) if (current_user && current_user.roles != "admin")
    user = User.find_by_id(params[:no])
    return respond_json({:error => "User not found"}) if user.nil?
    return respond_json({:error => "You can not change state of a super admin."}) if (user.isSuperadmin == 1)
    user.update(isActive: params[:isActive])
    return respond_ok
  end

  def new
    @user = User.new
    render :form, locals: { user: @user}
  end
end
