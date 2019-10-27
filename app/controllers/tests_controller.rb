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
