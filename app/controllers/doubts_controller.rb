class DoubtsController < ApplicationController
  before_action :set_doubt, only: [:show, :edit, :update, :destroy]

  # GET /doubts
  # GET /doubts.json
  def pending_stats
    @doubts_physics_two_days = Doubt.physics_paid_student_doubts_two_days
    @doubts_physics_five_days = Doubt.physics_paid_student_doubts_five_days
    @doubts_physics_seven_days = Doubt.physics_paid_student_doubts_seven_days

    @doubts_chemistry_two_days = Doubt.chemistry_paid_student_doubts_two_days
    @doubts_chemistry_five_days = Doubt.chemistry_paid_student_doubts_five_days
    @doubts_chemistry_seven_days = Doubt.chemistry_paid_student_doubts_seven_days

    @doubts_botany_two_days = Doubt.botany_paid_student_doubts_two_days
    @doubts_botany_five_days = Doubt.botany_paid_student_doubts_five_days
    @doubts_botany_seven_days = Doubt.botany_paid_student_doubts_seven_days

    @doubts_zoology_two_days = Doubt.zoology_paid_student_doubts_two_days
    @doubts_zoology_five_days = Doubt.zoology_paid_student_doubts_five_days
    @doubts_zoology_seven_days = Doubt.zoology_paid_student_doubts_seven_days
  end
end
