ActiveAdmin.register Test do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

permit_params :name, :description, :instructions, :durationInMin, :free, :showAnswer, :negativeMarks, :positiveMarks, :numQuestions, :exam, :startedAt, :expiryAt, :test_topic

index do
  id_column
  column :name
  column :description
  column :instructions do |test|
    raw(test.instructions)
  end
  column :durationInMin
  column :free
  column :showAnswer
  column :negativeMarks
  column :positiveMarks
  column :numQuestions
  column :exam
  column :startedAt
  column :expiryAt
  actions
end

show do
  attributes_table do
    row :name
    row :description
    row :instructions do |test|
      raw(test.instructions)
    end
    row :durationInMin
    row :free
    row :showAnswer
    row :negativeMarks
    row :positiveMarks
    row :numQuestions
    row :exam
    row :startedAt
    row :expiryAt
  end
end

form do |f|
  f.inputs "Test" do
    f.input :name, hint: "Mention the name of the test here, Eg. Scholarship test 2019"
    f.input :description
    f.input :instructions
    f.input :durationInMin, label: "Duration in Minutes"
    f.input :free, hint: "Mark checked for Live session test and Scholarship tests"
    f.input :showAnswer, hint: "Mark un-checked for Live session test and Scholarship tests"
    f.input :negativeMarks, label: "Negative Marks", hint: "No '-' sign is required"
    f.input :positiveMarks, label: "Positive Marks", hint: "No '+' sign is required"
    f.input :numQuestions, label: "Number of Questions"
    f.input :exam, as: :select, :collection => ["AIIMS", "NEET", "AIPMT", "JIPMER"], label: "Exam Type"
    f.input :startedAt, as: :datetime_picker, label: "Started Test At"
    f.input :expiryAt, as: :datetime_picker, label: "Expire Test At"
  end

  f.inputs "Additional Information" do
    f.input :name, hint: "Mention the name of the test here, Eg. Scholarship test 2019"
  end

  f.actions
end

end
