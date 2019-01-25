module Growl
  def growl(res, action, className)
    notice = "#{className} is now edited!"
    if action == "create"
      notice = "#{className} is created successfully!"
    end
    if res == true
      flash[:success] = notice
    else
      flash[:alert] = res
    end
  end

  def response_msg(res, className)
    result = ""
    if res[className].present?
      result = true
    elsif res["error"].present?
      result = res["error"]
    end
    result
  end
end