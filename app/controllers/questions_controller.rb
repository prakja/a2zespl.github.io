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
    @topicId = params[:topic]

    if @subject == 'physics' && @topicId
      @questions = Question.physics_mcqs_difficult(@topicId)
    elsif @subject == 'chemistry'  && @topicId
      @questions = Question.chemistry_mcqs_difficult(@topicId)
    elsif @subject == 'botany' && @topicId
      @questions = Question.botany_mcqs_difficult(@topicId)
    elsif @subject == 'zoology' && @topicId
      @questions = Question.zoology_mcqs_difficult(@topicId)
    end

    @questions.each do |question|
      @questions_data[question.id] = [question.question, question.explanation, question.question_analytic.correctPercentage]
    end

  end
end
