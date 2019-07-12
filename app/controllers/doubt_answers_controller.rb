class DoubtAnswersController < ApplicationController
  before_action :set_doubt_answer, only: [:show, :edit, :update, :destroy]

  # GET /doubt_answers
  # GET /doubt_answers.json
  def answer
    @doubt_id = params[:doubt_id]
    @doubt = Doubt.find(@doubt_id)
  end

  end
