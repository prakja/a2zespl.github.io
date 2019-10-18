class QuestionsController < ApplicationController
  before_action :set_doubt, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def pdf_questions
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @questions_data = {}
    @questions = {}
    @subject = params[:subject]
    @topicId = params[:topic]
    @orderBy = params[:order]
    @limit = params[:limit]

    if @subject == 'physics' && @topicId
      @questions = Question.physics_mcqs_difficult(@topicId)
    elsif @subject == 'chemistry'  && @topicId
      @questions = Question.chemistry_mcqs_difficult(@topicId)
    elsif @subject == 'botany' && @topicId
      @questions = Question.botany_mcqs_difficult(@topicId)
    elsif @subject == 'zoology' && @topicId
      @questions = Question.zoology_mcqs_difficult(@topicId)
    end

    if @orderBy == 'desc'
      @questions = @questions.order(correctPercentage: :desc)
    elsif @orderBy == 'asc'
      @questions = @questions.order(correctPercentage: :asc)
    end

    if @limit
      @questions = @questions.limit(@limit)
    end

    @questions.each do |question|
      @questions_data[question.id] = [question.question, question.explanation, question.question_analytic.correctPercentage]
    end

  end

  def update_explanation
    id = params.require(:id)
    new_explanation = params.require(:explanation)
    question = Question.find(id)
    current_explanation = question.explanation
    question.update(explanation: new_explanation + current_explanation)
  end

  def add_explanation
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end
    begin
      @questionId = params.require(:id)
      @question = Question.find(@questionId)
      @questionBody = @question.question
      @questionExplanation = @question.explanation

    rescue => exception
      
    end    
  end
  
  def test_question_pdf
    @questions_data = {}
    @testId = params.require(:id)

    begin
      @test = Test.find(@testId)
      @testQuestions = @test.questions

      @testQuestions.each do |question|
        @questions_data[question.id] = [question.question, question.explanation]
      end
    rescue => exception
      
    end
  end
end
