ActiveAdmin.register Test do
permit_params :name, :sections, :description, :instructions, :syllabus, :durationInMin, :free, :showAnswer, :negativeMarks, :positiveMarks, :numQuestions, :exam, :startedAt, :expiryAt, :topic, :ownerType, :ownerId, :courses, course_ids: []
remove_filter :topic, :questions, :test_leader_boards, :versions, :testQuestions, :testCourseTests

filter :id_eq, as: :number, label: "Test ID"
preserve_default_filters!

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
  column :exam
  column :startedAt
  column :expiryAt
  column ("Current Question Count") {|test| raw("<b>" + test.questions.count.to_s + "</b>") + "/" + raw(test.numQuestions)}
  column ("Get PDF") {|test| raw('<a target="_blank" href=https://www.neetprep.com/test-question/' + test.id.to_s + '?white&showId=true>Get PDF</a>')}
  column ("History") {|test| raw('<a target="_blank" href="/admin/tests/' + (test.id).to_s + '/history">View History</a>')}
  actions
end

member_action :history do
  @test = Test.find(params[:id])
  @versions = PaperTrail::Version.where(item_type: 'Test', item_id: @test.id)
  render "layouts/history"
end

show do
  attributes_table do
    row :id
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
    row ("Current Question Count") {|test| raw("<b>" + test.questions.count.to_s + "</b>") + "/" + raw(test.numQuestions)}
    row :exam
    row :startedAt
    row :expiryAt
    row :topic
    row :questions
    # row "Questions" do |test|
    #   test.questions.pluck(:id, :question).join("<br />").html_safe
    # end
  end
end

action_item :add_question, only: :show do
  link_to 'Add Question', '../../admin/questions/new?question[test_ids][]=' + resource.id.to_s
end

action_item :show_question, only: :show do
  link_to 'All Test Questions', "../../admin/questions?q[questionTests_testId_eq]=" + resource.id.to_s
end

action_item :show_leaderboard, only: :show do
  link_to 'LeaderBoard', "../../admin/test_leader_boards?order=score_desc&q[testId_eq]=" + resource.id.to_s
end

action_item :update_test_attempts, only: :show do
  link_to 'Update Test Attempts', Rails.configuration.node_site_url + 'api/v1/webhook/updateTestAttempts?testId=' + resource.id.to_s
end

form do |f|
  f.inputs "Test" do
    f.input :name, hint: "Mention the name of the test here, Eg. Scholarship test 2019"
    f.input :description
    f.input :instructions
    f.input :syllabus, as: :quill_editor
    f.input :durationInMin, label: "Duration in Minutes"
    f.input :free, hint: "Mark checked for Live session test and Scholarship tests"
    f.input :showAnswer, hint: "Mark un-checked only for Scholarship tests"
    f.input :negativeMarks, label: "Negative Marks", hint: "No '-' sign is required"
    f.input :positiveMarks, label: "Positive Marks", hint: "No '+' sign is required"
    f.input :numQuestions, label: "Number of Questions"
    f.input :exam, as: :select, :collection => ["AIIMS", "NEET", "AIPMT", "JIPMER"], label: "Exam Type"
    f.input :sections, hint: 'Required format for test sections - [["Physics", 1], ["Chemistry", 20], ["Biology", 40]]'
    f.input :startedAt, as: :datetime_picker, label: "Started Test At"
    f.input :expiryAt, as: :datetime_picker, label: "Expire Test At"
  end

  f.inputs "Additional Information" do
    f.input :topic, input_html: { class: "select2" }, :collection => Topic.name_with_subject,  hint: "Select topic (only applicable for live session test)"
    f.input :ownerType, as: :hidden, :input_html => { :value => 'topic' }
    f.input :courses, as: :select, :collection => Course.public_courses, input_html: { class: "select2" }, include_hidden: false, multiple: true
  end

  f.actions
end

end
