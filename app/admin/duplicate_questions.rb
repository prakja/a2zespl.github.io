ActiveAdmin.register DuplicateQuestion do
  remove_filter :question1, :question2, :versions

  index do
    if current_admin_user.admin?
      selectable_column
    end
    id_column
    column "Question1" do |dq|
      raw('<a href=' + edit_admin_question_path(dq.question1) + " target='_blank'>#{dq.question1.id}</a><br />" + dq.question1.question)
    end
    column "Question2" do |dq|
      raw('<a href=' + edit_admin_question_path(dq.question2) + " target='_blank'>#{dq.question2.id}</a><br />" + dq.question2.question)
    end
    actions
  end

  controller do
    def scoped_collection
      super.preload(:question1, :question2)
    end
  end
end
