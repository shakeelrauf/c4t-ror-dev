class SendFormController < ApplicationController
  layout 'login'
  # before_action :redirect_to_path, only: [:login]

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
    res = ApiCall.get("/users",{}, {"Content-Type": "application/x-www-form-urlencoded", "Authorization": token})
    users = res
    user = {}
    for i in users
      if i["username"] == params[:username]
        user = i
        break
      end
    end
    successful_login(user,token)
    return respond_ok
  end

  def logout
    reset_session
    redirect_to login_path
  end

  def forget_pw

  end

  def forgot_reset
    e = params["username"]
    user = User.find_by_username(e)
    if (user.present?)
      cfg =  user.cfg
      cfg.reinit_pw
      locals = {:key=>cfg.pw_reinit_key, :pid=>user.id.to_s}
      cfg.save!
      user.save!
      if ENV["POSTMARK_API_KEY"].present?
        res = render_to_string partial: "send_form/forgot_reset", locals: locals
        build_and_send_email_domain("Reset Password",
                                    "send_form/pass_init_email",
                                    user.email,
                                    locals)
      else
        res = render_to_string  "send_form/pass_init_email", locals: locals
      end
      respond_json({data: res})
    else
      respond_error("Username not found")
      logger.info("Forgot password person not found: " + e)
    end
  end
  #
  # def pw_init_revert
  #   p = Person.find(params[:person])
  #   key = params[:key]
  #   p.cfg.reinit_clear
  #   p.save!
  #   end_session
  #   redirect_to "/pw_init_reverted"
  # end
  #
  def change_pw_save
    u = current_user
    pw = params["pw_new"]
    pw_confirm = params["pw_confirm"]
    # Validate the pw match
    if (pw != pw_confirm)
      msg = "Password and confirm dont match #{pw} and #{pw_confirm}"
      logger.info msg
      return respond_error(msg)
    end
    # Validate the pw size
    if (pw.size < 8)
      msg = "Password too short: #{pw}"
      logger.info msg
      return respond_error(msg)
    end
    # Validate the pw contains a CAP
    cap_re = /[A-Z]/
    if (cap_re.match(pw).nil?)
      msg = "Password doesnt contain a cap #{pw}"
      logger.info msg
      return respond_error(msg)
    end
    # Validate the pw contains a CAP
    num_re = /[0-9]/
    if (num_re.match(pw).nil?)
      msg = "Password doesnt contain a number #{pw}"
      logger.info msg
      return respond_error(msg)
    end
    u.force_new_pw = false
    cfg = u.cfg
    cfg.reinit_clear
    cfg.save!
    u.salt = u.make_salt if (u.salt.nil? || u.salt.blank?)
    u.password = u.encrypt_pw(pw)
    u.save!
    start_session u, u.accessToken
    redirect_to "/dashboard"
  end

  def pw_init
    @u = User.find_by_id(params[:id])
    key = params[:key]
    if (!@u.cfg.pw_init_valid?(key))
      end_session    # Ensure there's no session here
      redirect_to "/invalid_key"
      return
    end
    @u.force_new_pw = true
    @u.save!
    start_session @u, @u.accessToken
    render "send_form/change_password"
  end

  private

  def redirect_to_path
    if current_user.present?
      redirect_to dashboard_path
    end
  end
end
