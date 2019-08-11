ActiveAdmin.register_page "User Engagements" do

  page_action :new_users_json, method: :get do
    render json: User.group_by_day(:createdAt, range: 1.months.ago.midnight..Time.now).count
  end

  page_action :solved_questions_json, method: :get do
    render json: Answer.group_by_day(:createdAt, range: 1.months.ago.midnight..Time.now).count
  end

  page_action :user_courses_json, method: :get do
    render json: UserCourse.group_by_day(:createdAt, range: 1.months.ago.midnight..Time.now).count
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
      tab :user_courses do
        render partial: 'user_courses'
      end
    end
  end
end
