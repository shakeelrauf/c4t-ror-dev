class Api::V1::UsersController < ApiController  
  before_action :set_user, only: [:show, :update, :destroy, :block_user]
  before_action :authenticate_user

  def create
	# Validate if user asked this is a super admin.
    if (current_user && current_user.roles != "admin")
    	return render_json_response({:error => "You are not a super admin."}, :ok)
    # Validate body data before insert.
    elsif (params[:firstName] == nil || params[:lastName] == nil || params[:email] == nil || !params[:pwd] || !params[:username] || params[:avatar] == nil || params[:roles] == nil || !params[:isSuperadmin])
    	return render_json_response({:error => "Please send all require attributes."}, :ok)
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
  			  return render_json_response(@user, :ok)
        else @user.errors.any?
          return render_json_response({:error => @user.errors.messages}, :ok)
        end
      else
  			return render_json_response({:error => "Username already exist."}, :ok)
      end
    end
  end

  # Update one user.
  def update
    if (current_user && current_user.roles != "admin" && current_user.idUser != params[:no])
      return render_json_response({:error => "You are not authorize to update this user."}, :ok)
    # Validate body data before update.
    elsif (params[:firstName] == nil || params[:lastName == nil] || !params[:email] || !params[:username] || params[:roles] == nil)
      return render_json_response({:error => "Please send all require attributes."}, :ok)
    else
      phoneNumber = Validations.phone(params[:phoneNumber])
      if (params[:phoneNumber] != "" && phoneNumber == false)
        return render_json_response({:error => "phoneNumber must contain a valid phone number."}, :bad_request)
      else
        if(params[:phoneNumber] == "")
          phoneNumber = nil
        end
        # Verify username not exist.
        @user_user = User.find_by_username(params[:username])
        if (@user_user && @user_user.id != params[:no].to_i)
          return render_json_response({:error => "Username already exist."}, :ok)
        else
          if (@user)
            @user.update(
            firstName: params[:firstName],
            lastName: params[:lastName],
            email: params[:email],
            username: params[:username],
            phone: params[:phoneNumber],
            roles: params[:roles])
          end
          # Update roles if user is an admin.
          if (current_user == "admin")
            @user.update(roles: params[:roles])
            # Update password if it's there too.
            if (params[:pwd] != nil)
              if(!@user)
                return render_json_response({:error => "User not found."}, :ok)
              else
                @user.update(password: params[:pwd])
                return render_json_response(@user, :ok)
              end
            else
              if(!@user)
                return render_json_response({:error => "User not found."}, :ok)
              else
                return render_json_response(@user, :ok)
              end 
            end
          else
          # Update password if it's there too.
            if (params[:pwd] != nil)
              if(!@user)
                return render_json_response({:error => "User not found."}, :ok)
              else
                @user.update(password: User.encrypt(params[:pwd]))
                return render_json_response(@user, :ok)
              end
            else
              if (!@user)
                return render_json_response({:error => "User not found."}, :ok)
              else
                return render_json_response(@user, :ok)
              end
            end
          end
        end
      end
    end
end
  # get all users
  def index
    @users = User.all
    @users.each do|user| 
      user.phone = "" if (user.phone == nil)
    end
    return render_json_response(@users, :ok)
  end

  def show
    if(!@user)
    	return render_json_response({:error => "User not found!"}, :ok)
    else
      if(@user.phone == nil) 
        @user.phone = ""
      end
    	return render_json_response(@user, :ok)
    end
  end

  # Remove a user
  def destroy
	  if (current_user && current_user.isSuperadmin != 1)
			return render_json_response({:error => "You are not a super admin!"}, :ok)
	  else
	    @user.destroy
			return render_json_response({:message => "User Deleted!"}, :ok)
	  end
  end

  # Blacklist user
  def block_user
    if (current_user && current_user.roles != "admin")
			return render_json_response({:error => "You are not allowed to change state of this user."}, :ok)
    else 
      if (@user.isSuperadmin == 1)
				return render_json_response({:error => "You can not change state of a super admin."}, :ok)
      else
        @user.update(isActive: params[:isActive])
        return render_json_response({:message => "User state has changed."}, :ok)
      end
    end
  end

    # Update avatar of specific user.
  def avatar
    @user = User.find_by_id(params[:user_no])
    if (current_user && current_user.roles != "admin" && current_user.idUser != params[:user_no])
      return render_json_response({:error => "You are not authorize to update this user."}, :ok)
    else
      if (params[:avatar] == nil)
        return render_json_response({:error => "Please send all require attributes."}, :ok)
      else
        if @user.update(avatar: params[:avatar])
          return render_json_response({:message => "User state has changed."}, :ok)
        else
          return render_json_response({:message => "User not found."}, :ok)
        end
      end
    end
  end

  def user_params
    params.permit(:firstName, :lastName, :username, :password, :email, :roles, :avatar, :phone, :isSuperadmin)
  end

  def set_user
    @user = User.find_by_id(params[:no])
  end
end
