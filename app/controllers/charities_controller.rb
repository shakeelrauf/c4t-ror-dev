class CharitiesController < ApplicationController
  # before_action :authenticate_user
  # before_action :authenticate_admin
  before_action :login_required
  before_action :set_charity , only: [:edit, :update]
  include Growl

  def create
    res = Charitie.new(charitie_params)
    res.save
    if res.save
      flash[:success] = "Charity Created Successfully"
      redirect_to charities_path
    else
      flash[:alert] = "Email is invalid."
      render "new", locals: { charitie: res }
    end
  end

  def index
    @charities = Charitie.all
  end

  def new
    @charitie = Charitie.new
    render :new, locals: { charitie: @charitie }
  end

  def edit
    @charitie = Charitie.find(params[:id])
    render :edit, locals: { charitie: @charitie }
  end

  def update
    @charitie = Charitie.find(params[:id])
    res = @charitie.update(charitie_params)
    if res
      flash[:success] = "Charity Updated Successfully"
      redirect_to charities_path
    else
      flash[:alert] = "Email is invalid."
      render :edit, locals: { charitie: @charitie }
    end
  end

  private
  def set_charity
  end

  def charitie_params
    params.permit(:name, :email, :address, :phone, :info)
  end
end