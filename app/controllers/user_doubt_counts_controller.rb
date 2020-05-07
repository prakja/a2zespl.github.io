class UserDoubtCountsController < ApplicationController
  before_action :set_user_doubt_count, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

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

  def answer_count
    @admin_users = AdminUser.where(role: "faculty")
    @faculty_id_list = @admin_users.pluck(:userId)
    @table = UniqueDoubtAnswer.joins(:user).where(['"userId" in (?)', AdminUser.where(role: "faculty").pluck(:userId)]).group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).group('userId').count("id")
    @final_data = {}
  
    @faculty_id_list.each do |userId|
      temp_val = []
      (1.months.ago.midnight.to_date ... 1.day.ago.midnight.to_date).each_with_index do |date, index|
        @table.each do |table_row|
          row_date = table_row[0][0]
          row_id = table_row[0][1]
          # p row_date, row_id
          if row_id == userId && row_date.to_date == date
            temp_val << table_row[1].to_i
          end
        end
        if temp_val.count < index + 1
          temp_val << 0
        end
      end
      if userId
        @final_data[User.try(:find, userId).try(:name)] = temp_val
      end
    end
  end
  
  # def answer_count
  #   @admin_users = AdminUser.where(role: "faculty")
  # end

  def get_count
    email = params[:email]
    admin_user = AdminUser.where(email: email).first
    start_date = params[:start_date]
    end_date = params[:end_date]
    doubt_answers_count = UniqueDoubtAnswer.where(userId: admin_user.userId, createdAt: DateTime.parse(start_date).midnight...DateTime.parse(end_date).midnight + 1.days).count
    response = {
      value: doubt_answers_count,
      userId: admin_user.userId
    }
    render json: response, :status => 200
  end
end
