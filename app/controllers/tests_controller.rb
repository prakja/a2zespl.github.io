class TestsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def createChapterTest
    begin
      @testId = params[:testId]
      @chapterId = params[:chapterId]
      @test = Test.where(id: @testId).first

      ChapterTest.create(chapterId: @chapterId, testId: @testId)

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception
      p exception
    end
  end

  # TODO: copied from neetpreprails and need to similar to that except security checks. so better way to do this?
  def questions
    id = params.require(:id)
    begin
      @test = Test.find(id)
      questions_count = @test.question_ids.count
      @test_questions = @test.questions.first(questions_count)
      render layout: false
    rescue => exception
      p exception
    end
  end

  # TODO: copied from neetpreprails and need to similar to that except security checks. so better way to do this?
  def questions_copy
    questions
  end

  def live_session_questions
    id = params.require(:id)
    begin
      @test = Test.find(id)
      questions_count = @test.question_ids.count
      @test_questions = @test.questions.first(questions_count)
      render layout: false
    rescue => exception
      p exception
    end
  end

  def add_question
    authenticate_admin_user!

    @testId = params[:testId]
    @test = Test.where(id: @testId).first
    @tests_data = {}
    @tests = Test.where(userId: nil).where('"createdAt" > current_timestamp - interval \'3 months\'').where.not(id: @test.id)
    @tests.each do |test|
      @tests_data[test.id] = [test.name]
    end
  end

  def update_and_sort
    ids = params[:ids]
    testId = params[:testId]

    ids.each_with_index do |id, index|
      TestQuestion.where(testId: testId, questionId: id).update_all(seqNum: index + 1)
    end

    respond_to do |format|
      format.js
    end
  end

  def crud_question
    authenticate_admin_user!

    @questions_data = {}
    @testId = params.require(:testId)
    @test = Test.find(@testId)
    @testQuestions = @test.questions.order(seqNum: :asc, id: :asc)
    @testQuestions.each_with_index do |question, index|
      @questions_data[question.id] = [question.question, index+1]
    end

  end

  def remove_test_question
    begin
      testId = params[:testId]
      questionIds = params[:questionIds]

      TestQuestion.where(testId: testId).where(questionId: questionIds).delete_all

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception
      p exception
    end
  end

  def add_sequence
    authenticate_admin_user!

    @testId = params[:testId]
    @test = Test.where(id: @testId).first
    @questions_data = ""

    @testQuestions = @test.questions.order(seqNum: :asc, id: :asc)
    @testQuestions.each do |question|
      @questions_data += question.id.to_s + ","
    end
  end

  def getTestQuestionsList
    @questions_data = {}
    @testId = params.require(:testId)
    @test = Test.find(@testId)
    @testQuestions = @test.questions.order(seqNum: :asc, id: :asc)
    @testQuestions.each do |question|
      @questions_data[question.id] = [question.question, question.sequenceId]
    end
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @questions_data.to_json, status: 200 }
    end
  end

  def createTestQuestion
    begin
      @testId = params[:testId]
      @sequenceId = params[:sequenceId]
      @questionIds = params[:questionIds].map(&:to_i)
      @test = Test.where(id: @testId).first
      @rowsArray = []
      question_ids = []

      @testQuestions = @test.questions.order(seqNum: :asc, id: :asc)
      @testQuestions.each do |question|
        question_ids.push(question.id)
      end

      @questionIds = @questionIds.uniq

      @questionIds = @questionIds - question_ids

      @questionIds.each do |questionId|
        @row = {}
        @row["testId"] = @test.id
        @row["questionId"] = questionId
        @row["seqNum"] = @sequenceId != "" ? @sequenceId.to_i : 0;
        @rowsArray.push(@row)
      end

      if(@questionIds.length() > 0)
        TestQuestion.create(@rowsArray)
      end

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception
      p exception
    end
  end

  def addTestQuestionSequence
    begin
      @sequenceIds = params[:sequenceIds]
      @questionIds = params[:questionIds]
      @testId = params[:testId]

      @questionIds.each_with_index do |questionId, index|
        TestQuestion.where('"testId" = ? and "questionId" = ?', @testId, questionId).update_all(seqNum: @sequenceIds[index])
      end

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception
     p exception
    end
  end

  def add_chapter_test
    authenticate_admin_user!

    @testId = params[:testId]
    @test = Test.where(id: @testId).first
    @courses_data = {}
    @courses = Course.public_courses
    @courses.each do |course|
      @courses_data[course.id] = [course.name]
    end
  end

  def getSubjectsList
    @subjects_data = {}
    @course = params.require(:courseId)
    @subjects = Subject.where(course: @course)
    @subjects.each do |subject|
      @subjects_data[subject.id] = [subject.name]
    end
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @subjects_data.to_json, status: 200 }
    end
  end

  def getChaptersList
    @chapters_data = {}
    @subject = params.require(:subjectId)
    @chapters = Topic.where(subject: @subject)
    @chapters.each do |chapter|
      @chapters_data[chapter.id] = [chapter.name]
    end
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @chapters_data.to_json, status: 200 }
    end
  end

end
