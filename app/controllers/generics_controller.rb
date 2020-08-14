class GenericsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def get_flashcard_stats
    @total_count = UserFlashCard.all.count
    @tatal_users = UserFlashCard.all.distinct.pluck(:userId).count
  end

  def bookmark_during
    start_date = params[:start_date]
    end_date = params[:end_date]

    @total_count = UserFlashCard.where(createdAt: DateTime.parse(start_date).midnight...DateTime.parse(end_date).midnight).count
    @tatal_users = UserFlashCard.where(createdAt: DateTime.parse(start_date).midnight...DateTime.parse(end_date).midnight).distinct.pluck(:userId).count
    response = {
      total_bookmark: @total_count,
      total_users: @tatal_users
    }
    render json: response, :status => 200
  end

  def give_course_access_aryan_raj_view
  end

  def bulk_notify
  end

  def send_bulk_notification
    myfile = params[:file]
    title = params[:title]
    message = params[:message]
    context = params[:context]
    action = params[:action]
    course = params[:course].to_i

    CSV.foreach(myfile.path) do |row|
      user_id = row[0]
      p "Giving course access to: " + user_id
      HTTParty.post(
        Rails.configuration.node_site_url + "api/v1/job/importantNewsNotification",
        body: {
          title: title,
          message: message,
          actionUrl: action,
          contextType: context,
          imageUrl: "",
          courseId: course,
          studentType: "Selected",
          userId: user_id.to_i
        }
      )

      sleep(1.second)
    end
  end

  def give_course_access_aryan_raj
    # mod = params[:mod]
    myfile = params[:file]
    access_date = params[:access_date].to_datetime
    title = params[:title]
    message = params[:message]

    p access_date
    @user_ids = []
    CSV.foreach(myfile.path) {|row| @user_ids << row[0]}
    @user_ids = @user_ids.reject(&:empty?).map(&:to_i)

    @user_ids -= [0]

    p @user_ids

    @user_courses = []
    @user_ids.each do |user_id|
      @user_courses << {
        expiryAt: access_date,
        createdAt: Time.now,
        updatedAt: Time.now,
        courseId: 255,
        userId: user_id,
        trial: true
      }
    end

    UserCourse.create!(@user_courses)

    @user_ids.each do |user_id|
      p "Sending Notificaiton to: " + user_id.to_s
      HTTParty.post(
        Rails.configuration.node_site_url + "api/v1/job/importantNewsNotification",
        body: {
          title: title,
          message: message,
          actionUrl: "https://www.neetprep.com/neet-course/255",
          contextType: "BuyCourse",
          imageUrl: "",
          courseId: 255,
          studentType: "Selected",
          userId: user_id
        }
      )

      sleep(1.second)
    end 
  rescue => exception
    p exception
    response = {
      error: "Error",
    }
    render json: response, :status => 500
  end

  def set_seq_id_back
    flashcard_id = params[:flashcard_id]
    flashcard = FlashCard.find(flashcard_id)
    chapter_id = flashcard.topics.first.id
    last_seqId = FlashCard.joins(:topicFlashCards).where(ChapterFlashCard: {chapterId: chapter_id}).order(seqId: :asc).pluck('"ChapterFlashCard"."seqId"').last
    chapterFlashCard = flashcard.topicFlashCards.first
    new_seq_id = 0
    cards_after_seqIds = FlashCard.joins(:topicFlashCards).where(ChapterFlashCard: {chapterId: chapter_id}).where('"ChapterFlashCard"."seqId" > ?', chapterFlashCard.seqId).order(seqId: :asc)
    p cards_after_seqIds
    cards_after_seqIds.each do |next_flashcard|
      if next_flashcard.id != flashcard_id
        current_seq = next_flashcard.topicFlashCards.first.seqId
        p "will update " + next_flashcard.id.to_s
        new_seq_id = current_seq
        next_flashcard.topicFlashCards.first.update(seqId: current_seq - 1)
      end
    end
    if new_seq_id != 0
      chapterFlashCard.update(seqId: new_seq_id)
    end
    response = {
      error: "Ok",
    }
    render json: response, :status => 200
  rescue => exception
    p exception
    response = {
      error: "Error",
    }
    render json: response, :status => 500
  end

  def get_user_activity
  end

  def user_activity
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end
    file = params[:file]

    @course_id = params[:course_id].to_i
    @course = Course.includes(subjects: :topics).find(@course_id)

    @course_subjects = @course.subjects

    @course_topics = []
    @subject_topics = {}
    @course_subjects.each do |subject|
      @course_topics += subject.topics
      if @subject_topics[subject.id].nil?
        @subject_topics[subject.id] = []
      end
      subject.topics.each do |topic|
        @subject_topics[subject.id] << topic.id
      end 
    end

    p @course_topics
    p @subject_topics

    @user_ids = []

    @user_activity = {}

    CSV.foreach(file.path) do |row|
      @user_ids << row[0]
      @user_activity[row[0]] = [false, false]
      # @course_topics.each do |course_topic|
      #   @user_activity[user_id] << Answer.where(questionId: Q course_topic.questions, userId: user_id).count
      # end
    end

    # @user_activity[user_id] = 
    # temp = Answer.where(questionId: Question.joins(:topics).where(Topic: {id: @course_topics}), userId: @user_ids).group('"Answer"."id", "Answer"."userId"')
    
    @course_offers = CourseOffer.where(email: User.where(id: @user_ids).pluck(:email), phone: User.where(id: @user_ids).pluck(:phone), courseId: @course_id, accepted: true).pluck(:email)
    # @course_offer = CourseOffer.where(userId: @user_ids, courseId: @course_id).group("userId")
    @course_offer_ids = User.where(email: @course_offers).pluck(:id)

    @user_course_ids = User.joins(:user_courses).where(User: {id: @user_ids}, UserCourse: {courseId: @course_id}).where('"UserCourse"."expiryAt" > ?', Time.now).pluck('"User"."id"') 
    # UserCourse.where(userId: @user_ids, courseId: @course_id).where('"UserCourse"."expiryAt" > ?', Time.now).pluck(:userId)
    p @user_course_ids

    @user_course_ids.each do |user_course_id|
      @user_activity[user_course_id] = [false, false] if @user_activity[user_course_id].nil?
      @user_activity[user_course_id][0] = true
    end

    @course_offer_ids.each do |course_offer_id|
      @user_activity[course_offer_id][1] = true
    end

    # render json: @user_activity, status: 200
  end
end