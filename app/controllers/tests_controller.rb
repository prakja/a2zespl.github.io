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

    end
  end

  def add_question
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @testId = params[:testId]
    @test = Test.where(id: @testId).first
    @tests_data = {}
    @tests = Test.where.not(id: @test.id)
    @tests.each do |test|
      @tests_data[test.id] = [test.name]
    end
  end

  def add_sequence
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

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
      @questionIds = params[:questionIds]
      @test = Test.where(id: @testId).first
      @rowsArray = []

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

      if @sequenceId != ""
        Question.where('id IN (?)', @questionIds).update_all(sequenceId: @sequenceId)
      end

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception

    end
  end

  def addTestQuestionSequence
    begin
      @sequenceIds = params[:sequenceIds]
      @questionIds = params[:questionIds]
      @testId = params[:testId]

      @questionIds.each_with_index do |questionId, index|
        TestQuestion.where('"testId" = ? and "questionId" = ?', @testId, questionId).update_all(seqNum: @sequenceIds[index])
        Question.find(questionId).update_column(:sequenceId, @sequenceIds[index])
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
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

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
