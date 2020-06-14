class GenericsController < ApplicationController
  def get_flashcard_stats
    @total_count = UserFlashCard.all.count
    @tatal_users = UserFlashCard.all.distinct.pluck(:userId).count
  end
end