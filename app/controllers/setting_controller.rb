class SettingController < ApplicationController
  include Settings
  # before_action :authenticate_user
  # before_action :authenticate_admin, only: [:all, :update]
  before_action :login_required

  def settings
    last_settings = Setting.where("dtCreated IN (SELECT MAX(dtCreated) FROM Settings GROUP BY name)")
  end

  def all
    @edited = false || params[:edited]
    @settings = Setting.all
  end

  def update
    update_settings
    flash[:success] = 'Setting is successfully Updated!'
    redirect_to settings_path
  end
end