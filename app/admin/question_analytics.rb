ActiveAdmin.register QuestionAnalytic do
  remove_filter :question

  show do
    attributes_table do
      columns_to_exclude = ["questionId"]
      (QuestionAnalytic.column_names - columns_to_exclude).each do |c|
        row c.to_sym
      end
      row :question do |qa|
        link_to qa.id, admin_question_path(qa.id)
      end
    end
  end
end
