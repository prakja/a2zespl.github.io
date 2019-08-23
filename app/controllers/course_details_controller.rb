class CourseDetailsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def show
    @course_id = params.require(:courseId)
    @course = Course.find(@course_id)
    
    @course_subjects = @course.subjects

    @course_topics = []
    @course_subjects.each do |subject|
      @course_topics += subject.topics
    end

    @course_topics_subTopics = {}
    @course_topics_videos = {}
    @course_topics_questions = {}

    @course_videos = []
    @course_questions = []
    @course_subTopics = []

    @course_topics.each do |topic|
      videos = topic.videos
      questions = topic.questions
      subtopics = topic.subTopics

      @course_videos += videos
      @course_questions += questions
      @course_subTopics += subtopics
    
      @course_topics_videos[topic.id] = videos.length
      @course_topics_questions[topic.id] = questions.length
      @course_topics_subTopics[topic.id] = subtopics.length
    end
  end
end
