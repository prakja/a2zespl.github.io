class QuestionsController < ApplicationController
  before_action :set_doubt, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def sub_topic_difficutly
    @topics = Topic.name_with_subject_hinglish
    @topicId = params[:topicId].to_i
    p @topicId
    if @topicId.nil?
      redirect_to "/questions/sub-topic-difficulty?topicId=622" 
      return
    end
    @current_topic_object = @topics.select { |topic| topic[1] == @topicId }[0]
    @current_topic = Topic.find(@current_topic_object[1])
    @sub_topic_objects = []
    @sub_topics = @current_topic.subTopics
    @sub_topics.each do |sub_topic|
      questions = Question.joins(:subTopics).joins(:question_analytic).where(SubTopic: {id: sub_topic.id}).where(QuestionAnalytics: {difficultyLevel: ['easy', 'medium', 'difficult']}).count
      easy_questions = Question.joins(:subTopics).joins(:question_analytic).where(SubTopic: {id: sub_topic.id}).where(QuestionAnalytics: {difficultyLevel: 'easy'}).count
      medium_questions = Question.joins(:subTopics).joins(:question_analytic).where(SubTopic: {id: sub_topic.id}).where(QuestionAnalytics: {difficultyLevel: 'medium'}).count
      difficult_questions = Question.joins(:subTopics).joins(:question_analytic).where(SubTopic: {id: sub_topic.id}).where(QuestionAnalytics: {difficultyLevel: 'difficult'}).count
      temp = {
        sub_topic_id: sub_topic.id,
        sub_topic_name: sub_topic.name,
        total_questions: questions,
        easy_questions: easy_questions,
        medium_questions: medium_questions,
        difficult_questions: difficult_questions
      }
      @sub_topic_objects << temp
    end
  end

  def sync_course_questions
    if not current_admin_user.admin?
      flash[:error] = "Unauthorized access to sync_course_questions"
      redirect_to "/admin/courses/" + id.to_s
      return
    end
    id = params.require(:id)
    ActiveRecord::Base.connection.execute('SELECT "SyncCourseQuestions" (' + id.to_s + ')')
    flash[:notice] = "Sync Completed!"
    redirect_to "/admin/courses/" + id.to_s
  end

  def sync_subject_questions
    if not current_admin_user.admin?
      flash[:error] = "Unauthorized access to sync_subject_questions"
      redirect_to "/admin/subjects/" + id.to_s
      return
    end
    id = params.require(:id)
    ActiveRecord::Base.connection.execute('SELECT "SyncSubjectQuestions" (' + id.to_s + ')')
    flash[:notice] = "Sync Completed!"
    redirect_to "/admin/subjects/" + id.to_s
  end

  def delete_from_question_banks
    if not current_admin_user.question_bank_owner?
      flash[:error] = "Unauthorized access to delete_from_question_banks"
      redirect_to "/admin/questions/" + id.to_s
      return
    end
    id = params.require(:id)
    ChapterQuestion.where(questionId: id.to_i).destroy_all
    flash[:notice] = "Deleted this question from all question banks!"
    redirect_to "/admin/questions/" + id.to_s
  end

  def translation_pdf
    authenticate_admin_user!

    @subject = params[:subject]
    @topicId = params[:topic]

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
      @questions = Question.subject_ids(55).topic(@topicId).joins(:completed_reviewed_translations).select('"Question"."id", "Question"."question", "Question"."explanation", "QuestionTranslation"."id" as translated_id, "QuestionTranslation"."question" as translated_question, "QuestionTranslation"."explanation" as translated_explanation')
    elsif @subject == 'chemistry'  && @topicId
      @questions = Question.subject_ids(54).topic(@topicId).joins(:completed_reviewed_translations).select('"Question"."id", "Question"."question", "Question"."explanation", "QuestionTranslation"."id" as translated_id, "QuestionTranslation"."question" as translated_question, "QuestionTranslation"."explanation" as translated_explanation')
    elsif @subject == 'botany' && @topicId
      @questions = Question.subject_ids(53).topic(@topicId).joins(:completed_reviewed_translations).select('"Question"."id", "Question"."question", "Question"."explanation", "QuestionTranslation"."id" as translated_id, "QuestionTranslation"."question" as translated_question, "QuestionTranslation"."explanation" as translated_explanation')
    elsif @subject == 'zoology' && @topicId
      @questions = Question.subject_ids(56).topic(@topicId).joins(:completed_reviewed_translations).select('"Question"."id", "Question"."question", "Question"."explanation", "QuestionTranslation"."id" as translated_id, "QuestionTranslation"."question" as translated_question, "QuestionTranslation"."explanation" as translated_explanation')
    end
  end

  def test_translation
    authenticate_admin_user!

    @testId = params[:test]
    raise "Test ID error" if @testId.nil?
    @test = Test.find(@testId)
    raise "Test null" if @test.nil?

    @questions = @test.questions.joins(:translations).select('"Question"."id", "Question"."question", "Question"."explanation", "QuestionTranslation"."id" as translated_id, "QuestionTranslation"."question" as translated_question, "QuestionTranslation"."explanation" as translated_explanation')
  rescue => exception
    render json: {
      error: exception,
    }, status: 500
  end

  def pdf_questions
    authenticate_admin_user!

    default_order = 'asc'
    default_limit = 50
    default_level = ['medium', 'difficult'];
    @questions_data = {}
    @questions = {}
    @subject = params[:subject]
    @topicId = params[:topic]
    @orderBy = params[:order] ? params[:order] : default_order
    @limit = params[:limit] ? params[:limit] : default_limit
    @level = params[:level] ? params[:level] : default_level

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
      @questions = Question.subject_id(55).topic(@topicId).includes(:question_analytic).where("QuestionAnalytics": {difficultyLevel: @level != nil ? @level : ['easy', 'medium', 'difficult']}).order(correctPercentage: :asc).limit(@limit);
    elsif @subject == 'chemistry'  && @topicId
      @questions = Question.subject_id(54).topic(@topicId).includes(:question_analytic).where("QuestionAnalytics": {difficultyLevel: @level != nil ? @level : ['easy', 'medium', 'difficult']}).order(correctPercentage: :asc).limit(@limit);
    elsif @subject == 'botany' && @topicId
      @questions = Question.subject_id(53).topic(@topicId).includes(:question_analytic).where("QuestionAnalytics": {difficultyLevel: @level != nil ? @level : ['easy', 'medium', 'difficult']}).order(correctPercentage: :asc).limit(@limit);
    elsif @subject == 'zoology' && @topicId
      @questions = Question.subject_id(56).topic(@topicId).includes(:question_analytic).where("QuestionAnalytics": {difficultyLevel: @level != nil ? @level : ['easy', 'medium', 'difficult']}).order(correctPercentage: :asc).limit(@limit);
    end
    #
    # if @orderBy == 'desc'
    #   @questions = @questions.order(correctPercentage: :desc)
    # elsif @orderBy == 'asc'
    #   @questions = @questions.order(correctPercentage: :asc)
    # end
    #
    # if @limit
    #   @questions = @questions.limit(@limit)
    # end

    @questions.each do |question|
      @questions_data[question.id] = [question.question, question.explanation.to_s.gsub('<iframe', '<iframe loading="lazy"'), question.question_analytic.correctPercentage, question.correctOptionIndex]
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

  def remove_video_link_hint
    authenticate_admin_user!
    begin
      @hintId = params.require(:hintId)
      QuestionHint.where(id: @hintId).update(videoLinkId: nil)
    rescue => exception
      exception
    end
  end

  def video_link_hint
    authenticate_admin_user!
    begin
      @videoHintId = params.require(:videoId)
      @hintId = params.require(:hintId)
      QuestionHint.where(id: @hintId).update(videoLinkId: @videoHintId)
     
    rescue => exception
      exception
    end
  end

  def add_hint 
    authenticate_admin_user!
    begin
      @question_hints_data = {}
      @videoList_data = {}
      @questionId = params.require(:id)
      @question = Question.find(@questionId)
      @questionBody = @question.question
      @questionHints = @question.hints.order(position: :asc, id: :asc).includes(videoLink: :video)
      @videoLinks =  VideoLink.joins(:video).all().pluck('"Video"."name"', :id,:name)
      @videoLinks.each do |data|
        @videoList_data[data[1]] = [data[0] +" - "+data[2]] 
      end
      @questionHints.each_with_index do |hint, index|
        @question_hints_data[hint.id] = [index+1, hint.hint,hint.videoLinkId,hint.videoLink != nil && hint.videoLink.name != nil && hint.videoLink.video != nil && hint.videoLink.video.name != nil ? hint.videoLink.video.name + ' ----> '+ hint.videoLink.name : "" ]
      end

    rescue => exception

    end
  end

  def create_hint_row
    id = params.require(:id)
    new_hints = JSON.parse(params.require(:hints)[0])
    
    question = Question.find(id)
    new_hints.each do |new_hint|
      QuestionHint.create(questionId: question.id, deleted: false, hint: new_hint["url"])
    end
  end

  def add_explanation
    authenticate_admin_user!
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
    @showTranslations = params[:showTranslation] && params[:showTranslation] === 'true' ? true : false

    begin
      @test = Test.find(@testId)
      @testQuestions = nil
      if @limit.to_i > 0
        @testQuestions = @test.questions.includes(:question_analytic, :explanations).limit(@limit.to_i).offset(@offset.to_i).order(seqNum: :asc, id: :asc)
      else
        @testQuestions = @test.questions.includes(:question_analytic, :explanations).order(seqNum: :asc, id: :asc)
      end

      @testQuestions.each_with_index do |question, index|
        @questions_data[question.id] = [
          question.question, 
          @showExplanation == true ? (question.explanations.map(&:explanation).join('<br />') + (question.explanations.length > 0 ? '<p>Only for checking. Not part of test question solution</p><hr />' : '') + question.explanation.to_s) : nil, 
          question.question_analytic != nil ?  question.question_analytic.correctPercentage : 0, question.correctOptionIndex != nil ? question.correctOptionIndex : nil , 
          index+1
        ]
      end
    rescue => exception
      p exception
    end
  end
end
