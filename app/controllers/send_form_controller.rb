class SendFormController < ApplicationController
  layout 'login'
  before_action :redirect_to_path, only: [:login]

  def login
  end

  def login_user
    return respond_error("Authentication failed!") if !params[:username].present? || !params[:password].present?
    body = {
        "client_id": params[:username],
        "client_secret": params[:password],
        "grant_type": "client_credentials"
    }
    res1 = ApiCall.post("/token", body,headers )
    return respond_error("Authentication failed!") if res1["error"]
    token = res1["access_token"]
    res = ApiCall.get("/users",{}, {"Content-Type": "application/x-www-form-urlencoded", "Authorization": "Bearer "+token})
    users = res
    user = {}
    for i in users
      if i["username"] == params[:username]
        user = i
        break
      end
    end
    successful_login(user,res1)
    return respond_ok
  end

  def logout
    reset_session
    redirect_to login_path
  end

  private

  def redirect_to_path
    if current_user.present?
      redirect_to dashboard_path
    end
  end
end
