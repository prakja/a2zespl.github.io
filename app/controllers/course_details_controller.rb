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

  def booster
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @paidUser = params[:paidUser] && params[:paidUser] === "false" ? false : true
    @days = params[:days] ? params[:days] : 30
    begin
      @users = nil
      if @paidUser === true  
        @users = User.connection.select_all("SELECT \"UVS\".\"userId\" AS \"uUserId\", \"totalVideos\", \"UserCourse\".\"courseId\", \"UserCourse1\".\"courseId\", \"UserProfile\".\"displayName\",\"User\".\"id\" AS \"userId\",\"User\".\"email\" AS \"email\",\"User\".\"phone\" AS \"phone\",\"UserProfile\".\"displayName\" AS \"displayName\",\"UserProfile\".\"phone\" AS \"uphone\",\"UserProfile\".\"email\" AS \"uemail\" FROM (SELECT \"UserVideoStat\".\"userId\" , COUNT (\"UserVideoStat\".\"userId\") AS \"totalVideos\" FROM \"UserVideoStat\" WHERE \"UserVideoStat\".\"videoId\" IN (SELECT \"ChapterVideo\".\"videoId\" FROM \"Subject\",\"Course\",\"SubjectChapter\",\"ChapterVideo\" WHERE  \"ChapterVideo\".\"chapterId\" = \"SubjectChapter\".\"chapterId\" AND \"SubjectChapter\".\"subjectId\" = \"Subject\".\"id\" AND \"Subject\".\"courseId\" = \"Course\".\"id\" AND \"Course\".\"id\" = 149 AND \"UserVideoStat\".\"createdAt\" > CURRENT_DATE - INTERVAL '" + @days.to_s + " days')  GROUP BY \"UserVideoStat\".\"userId\") AS \"UVS\" LEFT OUTER JOIN \"UserCourse\" ON \"UserCourse\".\"userId\" = \"UVS\".\"userId\" AND \"UserCourse\".\"courseId\" = 8 LEFT OUTER JOIN \"UserCourse\" AS \"UserCourse1\" ON \"UserCourse1\".\"userId\" = \"UVS\".\"userId\"  LEFT OUTER JOIN \"UserProfile\" ON \"UserProfile\".\"userId\" = \"UVS\".\"userId\"  LEFT OUTER JOIN \"User\" ON \"UVS\".\"userId\" = \"User\".\"id\" WHERE \"UserCourse\".\"courseId\" IS  NULL AND \"UserCourse1\".\"courseId\" IS NOT NULL ORDER BY \"totalVideos\" DESC");
      else
        @users = User.connection.select_all("SELECT \"UVS\".\"userId\" AS \"uUserId\", \"totalVideos\", \"UserCourse\".\"courseId\", \"UserCourse1\".\"courseId\", \"UserProfile\".\"displayName\",\"User\".\"id\" AS \"userId\",\"User\".\"email\" AS \"email\",\"User\".\"phone\" AS \"phone\",\"UserProfile\".\"displayName\" AS \"displayName\",\"UserProfile\".\"phone\" AS \"uphone\",\"UserProfile\".\"email\" AS \"uemail\" FROM (SELECT \"UserVideoStat\".\"userId\" , COUNT (\"UserVideoStat\".\"userId\") AS \"totalVideos\" FROM \"UserVideoStat\" WHERE \"UserVideoStat\".\"videoId\" IN (SELECT \"ChapterVideo\".\"videoId\" FROM \"Subject\",\"Course\",\"SubjectChapter\",\"ChapterVideo\" WHERE  \"ChapterVideo\".\"chapterId\" = \"SubjectChapter\".\"chapterId\" AND \"SubjectChapter\".\"subjectId\" = \"Subject\".\"id\" AND \"Subject\".\"courseId\" = \"Course\".\"id\" AND \"Course\".\"id\" = 149 AND \"UserVideoStat\".\"createdAt\" > CURRENT_DATE - INTERVAL '" + @days.to_s + " days')  GROUP BY \"UserVideoStat\".\"userId\") AS \"UVS\" LEFT OUTER JOIN \"UserCourse\" ON \"UserCourse\".\"userId\" = \"UVS\".\"userId\" AND \"UserCourse\".\"courseId\" = 8 LEFT OUTER JOIN \"UserCourse\" AS \"UserCourse1\" ON \"UserCourse1\".\"userId\" = \"UVS\".\"userId\"  LEFT OUTER JOIN \"UserProfile\" ON \"UserProfile\".\"userId\" = \"UVS\".\"userId\"  LEFT OUTER JOIN \"User\" ON \"UVS\".\"userId\" = \"User\".\"id\" WHERE \"UserCourse\".\"courseId\" IS  NULL AND \"UserCourse1\".\"courseId\" IS  NULL ORDER BY \"totalVideos\" DESC");
      end 
      
    rescue => exception
      
    end
    
  end
end
