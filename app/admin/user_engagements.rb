ActiveAdmin.register_page "User Engagements" do

  page_action :new_users_json, method: :get do
    render json: User.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).count
  end

  #page_action :paid_users_answers_month_json, method: :get do
  #  render json: Answer.paid_users_answers.group_by_month(:createdAt, format: "%b %Y").distinct.count("userId")
  #end

  #page_action :users_answers_month_json, method: :get do
  #  render json: Answer.group_by_month(:createdAt, format: "%b %Y").distinct.count("userId")
  #end

  page_action :solved_questions_unique_paid_users_json, method: :get do
    render json: Answer.paid_users_answers.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).distinct.count("userId")
  end

  page_action :solved_questions_unique_users_json, method: :get do
    render json: Answer.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).distinct.count("userId")
  end

  page_action :solved_questions_json, method: :get do
    render json: Answer.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).count
  end

  page_action :solved_questions_customers_json, method: :get do
    render json: Answer.paid_users_answers.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).count
  end

  page_action :user_courses_json, method: :get do
    render json: UserCourse.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).count
  end

  page_action :paid_users_video_stats_json, method: :get do
    render json: UserVideoStat.paid_users_video_stats.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).count
  end

  page_action :unpaid_users_video_stats_json, method: :get do
    render json: UserVideoStat.unpaid_users_video_stats.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).count
  end

  page_action :paid_student_doubts_json, method: :get do
    render json: Doubt.paid_student_doubts.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).count
  end

  page_action :schedule_items_users_json, method: :get do
    render json: ScheduleItemUser.group_by_day(:createdAt, range: 1.months.ago.midnight..1.day.ago.midnight).distinct.count("userId")
  end

  content do
    render partial: 'graph'
    tabs do
      tab :new_users do
        render partial: 'new_users'
      end
      tab :solved_questions do
        render partial: 'solved_questions'
      end
      tab :solved_questions_customers do
        render partial: 'solved_questions_customers'
      end
      tab :solved_questions_unique_users do
        render partial: 'solved_questions_unique_users'
      end
      tab :solved_questions_unique_paid_users do
        render partial: 'solved_questions_unique_paid_users'
      end
      tab :user_courses do
        render partial: 'user_courses'
      end
      #tab :paid_users_answers do
      #  render partial: 'paid_users_answers'
      #end
      tab :paid_users_video_stats do
        render partial: 'paid_users_video_stats'
      end
      tab :unpaid_users_video_stats do
        render partial: 'unpaid_users_video_stats'
      end
      tab :paid_student_doubts do
        render partial: 'paid_student_doubts'
      end
      tab :schedule_items_users_json do
        render partial: 'schedule_items_users'
      end
    end
  end
end
