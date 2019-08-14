class UserDoubtCountsController < ApplicationController
  before_action :set_user_doubt_count, only: [:show, :edit, :update, :destroy]

  # GET /user_doubt_counts
  # GET /user_doubt_counts.json
  def index
    userId=[params[:user]][0]
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
  end  
end
