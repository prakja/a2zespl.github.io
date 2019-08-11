ActiveAdmin.register_page "User Engagements" do
  content do
    render partial: 'graph'
    tabs do
      tab :active_users do
        render partial: 'active_users'
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
