class QuestionsController < ApplicationController
  before_action :set_doubt, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def pdf_questions
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    default_order = 'asc'
    default_limit = 50
    default_level = ['medium', 'difficult'];
    @questions_data = {}
    @questions = {}
    @subject = params[:subject]
    @topicId = params[:topic]
    @orderBy = params[:order] or default_order
    @limit = params[:limit] or default_limit
    @level = params[:level] or default_level

    @subjectListIds = {
      'physics' => 55,
      'chemistry' => 54,
      'botany' => 53,
      'zoology' => 56
    }
    @chapters_data = {}
    @chapters = Topic.where(subject: @subjectListIds[@subject])
    @chapters.each do |chapter|
      @chapters_data[chapter.id] = [chapter.name]
    end

    if @subject == 'physics' && @topicId
      @questions = Question.subject_name(55).topic(@topicId).includes(:question_analytic).where("QuestionAnalytics": {difficultyLevel: @level != nil ? @level : ['easy', 'medium', 'difficult']});
    elsif @subject == 'chemistry'  && @topicId
      @questions = Question.subject_name(54).topic(@topicId).includes(:question_analytic).where("QuestionAnalytics": {difficultyLevel: @level != nil ? @level : ['easy', 'medium', 'difficult']});
    elsif @subject == 'botany' && @topicId
      @questions = Question.subject_name(53).topic(@topicId).includes(:question_analytic).where("QuestionAnalytics": {difficultyLevel: @level != nil ? @level : ['easy', 'medium', 'difficult']});
    elsif @subject == 'zoology' && @topicId
      @questions = Question.subject_name(56).topic(@topicId).includes(:question_analytic).where("QuestionAnalytics": {difficultyLevel: @level != nil ? @level : ['easy', 'medium', 'difficult']});
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
      @questions_data[question.id] = [question.question, question.explanation, question.question_analytic.correctPercentage, question.correctOptionIndex]
    end

  end

  def easy_questions
    @subject = params[:subject]
    @orderBy = params[:order] or 'asc'
    @limit = params[:limit] or 50
    @offset = params[:offset] or 1
    @questions_data = {}
    @questions = {}

    @subjectListIds = {
      'physics' => 55,
      'chemistry' => 54,
      'botany' => 53,
      'zoology' => 56
    }

    if @subject == 'physics'
      @questions = Question.physics_mcqs.easy.includes(:topics, :question_analytic)
    elsif @subject == 'chemistry'
      @questions = Question.chemistry_mcqs.easy.includes(:topics, :question_analytic)
    elsif @subject == 'botany'
      @questions = Question.botany_mcqs.easy.includes(:question_analytic)
    elsif @subject == 'zoology'
      @questions = Question.zoology_mcqs.easy.includes(:question_analytic)
    end

    if @orderBy == 'desc'
      @questions = @questions.order(correctPercentage: :desc)
    elsif @orderBy == 'asc'
      @questions = @questions.order(correctPercentage: :asc)
    end

    @count = @questions.count

    # if @limit
    #   @questions = @questions.limit(@limit)
    # end

    # if @offset
    #   @questions = @questions.offset(@offset)
    # end

    topic_list = []
    @questions.each do |question|
      topic_list = []
      question.topics.each do |topic|
        topic_list << topic.name
      end
      @questions_data[question.id] = [question.question, question.question_analytic.correctPercentage, topic_list]
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
    @limit = params[:limit] || 0
    @offset = params[:offset] || 0
    @showExplanation = params[:showExplanation] && params[:showExplanation] === "false" ? false : true

    begin
      @test = Test.find(@testId)
      @testQuestions = nil
      if @limit.to_i > 0
        @testQuestions = @test.questions.limit(@limit.to_i).offset(@offset.to_i).order(seqNum: :asc, id: :asc)
      else
        @testQuestions = @test.questions.order(seqNum: :asc, id: :asc)
      end

      @testQuestions.each_with_index do |question, index|
        @questions_data[question.id] = [question.question, @showExplanation == true ? question.explanation : nil, question.question_analytic != nil ?  question.question_analytic.correctPercentage : 0, question.correctOptionIndex != nil ? question.correctOptionIndex : nil , index+1]
      end
    rescue => exception

    end
  end
end
