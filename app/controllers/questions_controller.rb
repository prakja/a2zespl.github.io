class QuestionsController < ApplicationController
  before_action :set_doubt, only: [:show, :edit, :update, :destroy]

  def pdf_questions
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @questions_data = {}
    @questions = {}
    @subject = params[:subject]

    if @subject == 'physics'
      @questions = Question.physics_mcqs_difficult
    elsif @subject == 'chemistry'
      @questions = Question.chemistry_mcqs_difficult
    elsif @subject == 'botany'
      @questions = Question.botany_mcqs_difficult
    elsif @subject == 'zoology'
      @questions = Question.zoology_mcqs_difficult
    end

    @questions.each do |question|
      @questions_data[question.id] = [question.question, question.explanation]
    end

  end
end
