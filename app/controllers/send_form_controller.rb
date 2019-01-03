class SendFormController < ApplicationController
  layout 'login'
  before_action :redirect_to, only: [:login]

  def login

  end

  def login_user
    return render_json_response({error: "bad authentication"}, :ok) if !params[:username].present? || !params[:password].present?
    body = {
        "client_id": params[:username],
        "client_secret": params[:password],
        "grant_type": "client_credentials"
    }
    res = ApiCall.post("/token", body,headers )
    return render_json_response({error: "bad authentication"}, :ok) if res["error"]
    token = res["access_token"]
    res = ApiCall.get("/users",{}, {"Content-Type": "application/x-www-form-urlencoded", "Authorization": "Bearer "+token})
    users = res.to_json
    user = {}
    for i in users
      if i.username == params[:username]
        user = i
        return
      end
    end
    successful_login(user,token)
    return render_json_response({message:"authenticated"}, :ok)
  end

  private

  def redirect_to
    if current_user.present?
      redirect_to dashboard_path
    end
  end
end
