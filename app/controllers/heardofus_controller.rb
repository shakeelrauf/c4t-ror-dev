class HeardofusController < ApplicationController
  # before_action :authenticate_admin
  before_action :login_required
  before_action :check_heardofus, only: [:heardsofus, :update, :edit]

  def create
    hou = Heardofus.find_by_type(params[:type])
    if hou.nil?
      hou = Heardofus.new(type: params[:type])
      hou.save!
      flash[:success] = "Created"
      redirect_to "/heardofus"
    else
      flash[:error] = "Name already exist"
      redirect_to "/heardofus/add"
    end
  end

  def index
    @heardsOfUs = Heardofus.all
    render :index
  end

  def new
  end

  def edit
  end

  def update
    @heardofus.update(type: params[:type])
    flash[:success] = "Edited"
    redirect_to "/heardofus"
  end

  private
  def check_heardofus
    @heardofus = Heardofus.find_by_id(params[:no])
  end
end
