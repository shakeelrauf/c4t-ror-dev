module Users

  def create_user(current_user, params)
    if (current_user && current_user.roles != "admin")
      return respond_error("You are not a super admin.")
      # Validate body data before insert.
    elsif (params[:firstName] == nil || params[:lastName] == nil || params[:email] == nil || !params[:pwd] || !params[:username] || params[:avatar] == nil || params[:roles] == nil || !params[:isSuperadmin])
      return respond_error("Please send all require attributes.")
    else
      if params[:phoneNumber] == ""
        params[:phoneNumber] = nil
      end
      # Verify username not exist.
      @user = User.find_or_initialize_by(username: params[:username])
      if @user.new_record?
        @user.firstName = params[:firstName]
        @user.lastName = params[:lastName]
        @user.password = params[:pwd]
        @user.email = params[:email]
        @user.roles = params[:roles]
        @user.avatar = params[:avatar]
        @user.phone = params[:phoneNumber]
        @user.isSuperadmin = params[:isSuperadmin]
        if @user.save
          flash[:success] = 'User is successfully Created!'
          return render_json_response(@user, :ok)
        else @user.errors.any?
          return respond_json({:error => @user.errors.messages})
        end
      else
        return respond_error("Username Already exist")
      end
    end
  end

  def update_user
    return respond_json({:error => "You are not authorize to update this user."}) if (current_user && current_user.roles != "admin" && current_user.idUser != params[:no])
    return respond_json({:error => "Please send all require attributes."}) if (params[:firstName] == nil || params[:lastName == nil] || !params[:email] || !params[:username] || params[:roles] == nil)
    phoneNumber = Validations.phone(params[:phoneNumber])
    username_user = User.find_by_username(params[:username])
    return respond_json({:error => "Username already exist."}) if (username_user && username_user.idUser != params[:no].to_i)
    user =  User.find_by_id(params[:no])
    return respond_json({:error => "Username already exist."}) if (user.nil?)
    return respond_json({:error => "phoneNumber must contain a valid phone number."}) if (params[:phoneNumber] != "" && phoneNumber == false)
    phoneNumber = nil if(params[:phoneNumber] == "")
    user.firstName, user.lastName, user.email , user.username, user.phone= params[:firstName], params[:lastName], params[:email], params[:username],params[:phoneNumber]
    user.roles=params[:roles] if current_user.roles == "admin"
    user.password = User.encrypt(params[:pwd]) if params[:pwd] !=nil
    user.save!
    flash[:success] = "User has updated! "
    return respond_json(user)
  end
end