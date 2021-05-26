ActiveAdmin.register NotDuplicateQuestion do
  remove_filter :question1, :question2, :versions
  permit_params :questionId1, :questionId2

  scope :marked_duplicate, show_count: false
  scope :botany_marked_duplicates, show_count: false do |ndqs|
    ndqs.subject_marked_duplicates(53)
  end
  scope :chemistry_marked_duplicates, show_count: false do |ndqs|
    ndqs.subject_marked_duplicates(54)
  end
  scope :physics_marked_duplicates, show_count: false do |ndqs|
    ndqs.subject_marked_duplicates(55)
  end
  scope :zoology_marked_duplicates, show_count: false do |ndqs|
    ndqs.subject_marked_duplicates(56)
  end
  scope :unknown_subject_marked_duplicates, show_count: false do |ndqs|
    ndqs.subject_marked_duplicates
  end

  index do
    render partial: 'mathjax'
    if current_admin_user.question_bank_owner?
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

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Not Duplicate Question" do 
      f.input :questionId1, as: :number
      f.input :questionId2, as: :number
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.preload(:question1, :question2)
    end
  end
end
