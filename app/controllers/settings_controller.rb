class SettingsController < ApplicationController
  include Settings
  # before_action :authenticate_user
  # before_action :authenticate_admin, only: [:all, :update]
  before_action :login_required

  def settings
    last_settings = Setting.where("dtCreated IN (SELECT MAX(dtCreated) FROM settings GROUP BY name)")
  end

  def index
    @edited = false || params[:edited]
    @settings = Setting.init_settings
  end

  def update
    if params[:max_purchaser_increase].to_f > params[:max_increase_with_admin_approval].to_f
      flash[:danger] = "Max Increase With Admin Approval must be greater than Max purchaser Increase"
    else
      update_settings
      flash[:success] = 'Setting is successfully Updated!'
    end
    redirect_to settings_path
  end
end
