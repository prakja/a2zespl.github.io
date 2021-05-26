ActiveAdmin.register DuplicateQuestion do
  remove_filter :question1, :question2, :versions
  permit_params :questionId1, :questionId2

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

  batch_action :remove_duplicates_from_question_bank, confirm: "Are you sure to remove questions from question banks??", if: proc{current_admin_user.question_bank_owner?} do |ids|
    batch_action_collection.find(ids).each do |dq|
      dq.remove_duplicate_from_question_bank
    end
    redirect_back fallback_location: collection_path, notice: "Duplicates removed from question banks."
  end

  batch_action :destroy, confirm: "Are you sure to delete these entries??", if: proc{current_admin_user.admin?} do |ids|
    batch_action_collection.find(ids).each do |dq|
      dq.destroy
    end
    redirect_back fallback_location: collection_path, notice: "Removed selected entries."
  end

  member_action :remove_duplicate_from_question_bank, method: :post do
    resource.remove_duplicate_from_question_bank
    redirect_back fallback_location: collection_path, notice: "Duplicate removed from question banks."
  end

  member_action :destroy, method: :delete do
    resource.destroy
    redirect_back fallback_location: collection_path, notice: "Removed the entry."
  end

  index do
    render partial: 'mathjax'
    if current_admin_user.question_bank_owner?
      selectable_column
    end
    id_column
    column "Question1" do |dq|
      raw('<a href=' + edit_admin_question_path(dq.question1) + " target='_blank'>#{dq.question1.id}</a><br />" + dq.question1.question)
    end
    column "Question2" do |dq|
      raw('<a href=' + edit_admin_question_path(dq.question2) + " target='_blank'>#{dq.question2.id}</a><br />" + dq.question2.question)
    end
    column :similarity
    actions defaults: true do |dq|
      item 'Dedupe QB', remove_duplicate_from_question_bank_admin_duplicate_question_path(dq), class: 'member_link', method: :post, data: {confirm: "Please confirm that these questions are duplicate and 1 of them can be removed from question bank"}
    end
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

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Duplicate Question" do 
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
