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

  def give_course_access_aryan_raj
    # mod = params[:mod]
    myfile = params[:file]
    access_date = params[:access_date].to_datetime
    title = params[:title]
    message = params[:message]

    p access_date
    CSV.foreach(myfile.path) do |row|
      user_id = row[0]
      p "Giving course access to: " + user_id
      UserCourse.create(
        expiryAt: access_date,
        createdAt: Time.now,
        updatedAt: Time.now,
        courseId: 255,
        userId: user_id.to_i,
      )

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
          userId: user_id.to_i
        }
      )

      sleep(1.second)
    end 
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
end