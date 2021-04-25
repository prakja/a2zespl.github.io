ActiveAdmin.register NotDuplicateQuestion do
  remove_filter :question1, :question2, :versions

  scope :marked_duplicate, show_count: false
  index do
    render partial: 'mathjax'
    if current_admin_user.admin?
      selectable_column
    end
    id_column
    column "Question1" do |ndq|
      raw('<a href=' + edit_admin_question_path(ndq.question1) + " target='_blank'>#{ndq.question1.id}</a><br />" + ndq.question1.question)
    end
    column "Question2" do |ndq|
      raw('<a href=' + edit_admin_question_path(ndq.question2) + " target='_blank'>#{ndq.question2.id}</a><br />" + ndq.question2.question)
    end
    actions
  end

  show do
    render partial: 'mathjax'
    attributes_table do
      row :id
      row  "Question1" do |ndq|
        raw('<a href=' + edit_admin_question_path(ndq.question1) + " target='_blank'>#{ndq.question1.id}</a><br />" + ndq.question1.question)
      end
      row "Question2" do |ndq|
        raw('<a href=' + edit_admin_question_path(ndq.question2) + " target='_blank'>#{ndq.question2.id}</a><br />" + ndq.question2.question)
      end
      row "Contradicting Duplicate Question" do |ndq|
        if ndq.contradiction
          link_to "View Duplicate Question", admin_duplicate_question_path(ndq.contradiction), target: "_blank"
        else
          "No Contradiction found"
        end
      end
    end
    active_admin_comments
  end

  controller do
    def scoped_collection
      super.preload(:question1, :question2)
    end
  end
end
