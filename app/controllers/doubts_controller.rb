class DoubtsController < ApplicationController
  before_action :set_doubt, only: [:show, :edit, :update, :destroy]

  # GET /doubts
  # GET /doubts.json
  def index
    @doubts_physics_two_days = Doubt.physics_paid_student_doubts.where(createdAt: 2.days.ago..DateTime::Infinity.new)
    @doubts_physics_five_days = Doubt.physics_paid_student_doubts.where(createdAt: 5.days.ago..DateTime::Infinity.new)
    @doubts_physics_seven_days = Doubt.physics_paid_student_doubts.where(createdAt: 7.days.ago..DateTime::Infinity.new)

    @doubts_chemistry_two_days = Doubt.chemistry_paid_student_doubts.where(createdAt: 2.days.ago..DateTime::Infinity.new)
    @doubts_chemistry_five_days = Doubt.chemistry_paid_student_doubts.where(createdAt: 5.days.ago..DateTime::Infinity.new)
    @doubts_chemistry_seven_days = Doubt.chemistry_paid_student_doubts.where(createdAt: 7.days.ago..DateTime::Infinity.new)

    @doubts_botany_two_days = Doubt.botany_paid_student_doubts.where(createdAt: 2.days.ago..DateTime::Infinity.new)
    @doubts_botany_five_days = Doubt.botany_paid_student_doubts.where(createdAt: 5.days.ago..DateTime::Infinity.new)
    @doubts_botany_seven_days = Doubt.botany_paid_student_doubts.where(createdAt: 7.days.ago..DateTime::Infinity.new)

    @doubts_zoology_two_days = Doubt.zoology_paid_student_doubts.where(createdAt: 2.days.ago..DateTime::Infinity.new)
    @doubts_zoology_five_days = Doubt.zoology_paid_student_doubts.where(createdAt: 5.days.ago..DateTime::Infinity.new)
    @doubts_zoology_seven_days = Doubt.zoology_paid_student_doubts.where(createdAt: 7.days.ago..DateTime::Infinity.new)
    
  end

  # GET /doubts/1
  # GET /doubts/1.json
  def show
  end

  # GET /doubts/new
  def new
    @doubt = Doubt.new
  end

  # GET /doubts/1/edit
  def edit
  end

  # POST /doubts
  # POST /doubts.json
  def create
    @doubt = Doubt.new(doubt_params)

    respond_to do |format|
      if @doubt.save
        format.html { redirect_to @doubt, notice: 'Doubt was successfully created.' }
        format.json { render :show, status: :created, location: @doubt }
      else
        format.html { render :new }
        format.json { render json: @doubt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /doubts/1
  # PATCH/PUT /doubts/1.json
  def update
    respond_to do |format|
      if @doubt.update(doubt_params)
        format.html { redirect_to @doubt, notice: 'Doubt was successfully updated.' }
        format.json { render :show, status: :ok, location: @doubt }
      else
        format.html { render :edit }
        format.json { render json: @doubt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /doubts/1
  # DELETE /doubts/1.json
  def destroy
    @doubt.destroy
    respond_to do |format|
      format.html { redirect_to doubts_url, notice: 'Doubt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_doubt
      @doubt = Doubt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def doubt_params
      params.fetch(:doubt, {})
    end
end
