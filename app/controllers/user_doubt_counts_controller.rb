class UserDoubtCountsController < ApplicationController
  before_action :set_user_doubt_count, only: [:show, :edit, :update, :destroy]

  # GET /user_doubt_counts
  # GET /user_doubt_counts.json
  def stats
    userId=[params[:user]][0]
    startDate = [params[:startDate]][0]
    endDate = [params[:endDate]][0]

    if startDate.blank? && endDate.blank?
      endDate = Date.current
      startDate = endDate.last_month
      redirect_to "/user_doubt_counts/stats?user=" + userId.to_s + "&startDate=" + startDate.year.to_s + "-" + startDate.month.to_s.rjust(2, '0') + "-" + startDate.day.to_s.rjust(2, '0') + "&endDate=" + endDate.year.to_s + "-" + endDate.month.to_s.rjust(2, '0') + "-" + endDate.day.to_s.rjust(2, '0')
    end

    begin
      @user = User.find(userId)
    rescue ActiveRecord::RecordNotFound
      raise
    end

    @doubts_subject = Hash.new
    Subject.where(id: [53, 54, 55, 56]).each do |subject|
      doubts = Doubt.joins(:topic => :subjects).where(userId: @user.id, deleted: [true, false], topic: {Subject: {id: subject.id}})
      if not doubts.blank?
        @doubts_subject[subject] = doubts
      end
    end

    @doubts_subject_time = Hash.new
    Subject.where(id: [53, 54, 55, 56]).each do |subject|
      doubts = Doubt.joins(:topic => :subjects)
                .where(userId: @user.id, deleted: [true, false], topic: {Subject: {id: subject.id}})
                .where('"Doubt"."createdAt" > ? AND "Doubt"."createdAt" < ?', startDate, endDate)
      if not doubts.blank?
        @doubts_subject_time[subject] = doubts
      end
    end
  end  
end
