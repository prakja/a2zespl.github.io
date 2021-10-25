class VideosController < ApplicationController
  before_action :set_doubt, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def createChapterVideo
    begin
      @videoId = params[:videoId]
      @chapterId = params[:chapterId]
      @video = Video.where(id: @videoId).first

      ChapterVideo.create(chapterId: @chapterId, videoId: @videoId)

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception

    end
  end

  def add_chapter_video
    authenticate_admin_user!

    @videoId = params[:videoId]
    @video = Video.where(id: @videoId).first
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
    @chapters = Topic.includes(:topicSubjects).where(SubjectChapter: {subjectId: @subject})
    @chapters.each do |chapter|
      @chapters_data[chapter.id] = [chapter.name]
    end
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @chapters_data.to_json, status: 200 }
    end
  end

end
