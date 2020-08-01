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

  def set_seq_id_back
    flashcard_id = params[:flashcard_id]
    # chapter_id = params[:chapter_id].to_i
    flashcard = FlashCard.find(flashcard_id)
    chapter_id = flashcard.topics.first.id
    last_seqId = FlashCard.joins(:topicFlashCards).where(ChapterFlashCard: {chapterId: chapter_id}).order(seqId: :asc).pluck('"ChapterFlashCard"."seqId"').last
    chapterFlashCard = flashcard.topicFlashCards.first
    new_seq_id = 0
    # chapterFlashCard.update(seqId: last_seqId + 1);
    cards_after_seqIds = FlashCard.joins(:topicFlashCards).where(ChapterFlashCard: {chapterId: chapter_id}).where('"ChapterFlashCard"."seqId" > ?', chapterFlashCard.seqId).order(seqId: :asc)
    cards_after_seqIds.each do |next_flashcard|
      if next_flashcard.id != flashcard_id
        current_seq = next_flashcard.topicFlashCards.first.seqId
        new_seq_id = current_seq
        next_flashcard.topicFlashCards.update(seqId: current_seq - 1)
      end
    end
    chapterFlashCard.update(seqId: new_seq_id)
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