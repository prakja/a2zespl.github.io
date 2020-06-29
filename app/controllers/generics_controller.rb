class GenericsController < ApplicationController
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
end