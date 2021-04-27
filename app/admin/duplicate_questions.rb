ActiveAdmin.register DuplicateQuestion do
  remove_filter :question1, :question2, :versions

  scope :question_bank_duplicates, show_count: false
  scope :botany_question_bank_duplicates, show_count: false do |dqs|
    dqs.subject_question_bank_duplicates(53)
  end
  scope :chemistry_question_bank_duplicates, show_count: false do |dqs|
    dqs.subject_question_bank_duplicates(54)
  end
  scope :physics_question_bank_duplicates, show_count: false do |dqs|
    dqs.subject_question_bank_duplicates(55)
  end
  scope :zoology_question_bank_duplicates, show_count: false do |dqs|
    dqs.subject_question_bank_duplicates(56)
  end
  scope :unknown_subject_question_bank_duplicates, show_count: false do |dqs|
    dqs.subject_question_bank_duplicates
  end

  batch_action :remove_duplicates_from_question_bank, if: proc{current_admin_user.admin?} do |ids|
    batch_action_collection.find(ids).each do |dq|
      dq.remove_duplicate_from_question_bank
    end
    redirect_back fallback_location: collection_path, notice: "Duplicates removed from question banks."
  end

  index do
    render partial: 'mathjax'
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

  show do
    render partial: 'mathjax'
    attributes_table do
      row :id
      row  "Question1" do |dq|
        raw('<a href=' + edit_admin_question_path(dq.question1) + " target='_blank'>#{dq.question1.id}</a><br />" + dq.question1.question)
      end
      row "Question2" do |dq|
        raw('<a href=' + edit_admin_question_path(dq.question2) + " target='_blank'>#{dq.question2.id}</a><br />" + dq.question2.question)
      end
      row "Question Bank Duplicates" do |dq|
        if dq.question_bank_chapter_id
          link_to "Remove Duplication", duplicate_questions_admin_topic_path(dq.question_bank_chapter_id, {questionId1: dq.question1.id, questionId2: dq.question2.id}), target: "_blank"
        else
          "Not Duplicated in Question Bank"
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
