class SendFormController < ApplicationController
  layout 'login'

  def login

  end

  def login_user
    return render_json_response({error: "bad authentication"}, :ok) if !params[:username].present? || !params[:password].present?
    body = {
        "client_id": params[:username],
        "client_secret": params[:password],
        "grant_type": "client_credentials"
    }
    res = ApiCall.post("/token", body, {"Content-Type": "application/x-www-form-urlencoded"})
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
    session[:user] = user
    return render_json_response({message:"authenticated"}, :ok)
  end
end
