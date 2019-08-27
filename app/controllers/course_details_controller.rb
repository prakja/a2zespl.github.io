class CourseDetailsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def show
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end
    @course_id = params.require(:courseId)
    @course = Course.includes(subjects: :topics).find(@course_id)
    
    @course_subjects = @course.subjects

    @course_topics = []
    @course_subjects.each do |subject|
      @course_topics += subject.topics
    end

    @course_topics_subTopics = {}
    @course_topics_videos = {}
    @course_topics_questions = {}

    @course_videos_count = 0
    @course_questions_count = 0
    @course_subTopics_count = 0  



    @course_topics.each do |topic|
      # videos = topic.videos
      # questions = topic.questions
      # subtopics = topic.subTopics

      # @course_videos += videos
      # @course_questions += questions
      # @course_subTopics += subtopics
    
      @course_topics_videos[topic.id] = topic.videos.count
      @course_topics_questions[topic.id] = topic.questions.count
      @course_topics_subTopics[topic.id] = topic.subTopics.count

      @course_subTopics_count += @course_topics_subTopics[topic.id]
    end
  end
end
