ActiveAdmin.register Test do
permit_params :name, :sections, :description, :resultMsgHtml, :instructions, :syllabus, :durationInMin, :free, :showAnswer, :negativeMarks, :positiveMarks, :numQuestions, :exam, :startedAt, :expiryAt, :ownerType, :ownerId, course_ids: [], topic_ids: []
remove_filter :questions, :test_leader_boards, :versions, :testQuestions, :testCourseTests, :testChapterTests

filter :id_eq, as: :number, label: "Test ID"
filter :courses, as: :searchable_select, multiple: true, collection: -> {Course.public_courses}, label: "Course"
filter :topics, as: :searchable_select, multiple: true, collection: -> {Topic.name_with_subject}, label: "Topic"

preserve_default_filters!

scope :neet_course
scope :test_series_2018
scope :test_series_2019

scope :botany
scope :chemistry
scope :physics
scope :zoology

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
  column ("All Questions") {|test| link_to 'All Test Questions', "../../admin/questions?order=sequenceId_asc_and_id_asc&showProofRead=yes&q[questionTests_testId_eq]=" + test.id.to_s}
  column ("Get PDF") {|test| raw('<a target="_blank" href=https://www.neetprep.com/test-question/' + test.id.to_s + '?white&showId=true&orderBy=SEQASC>Get PDF</a>')}
  column ("Get PDF with Solution") {|test| raw('<a target="_blank" href=https://admin1.neetprep.com/questions/test_question_pdf/' + test.id.to_s + '>Get PDF with Solution</a>')}
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
    row :topics
    row "Questions" do |test|
      test.questions_with_number.html_safe
    end
  end
end

action_item :add_question, only: :show do
  link_to 'Add Question', '../../admin/questions/new?question[test_ids][]=' + resource.id.to_s
end

action_item :show_question, only: :show do
  link_to 'All Test Questions', "../../admin/questions?order=sequenceId_asc_and_id_asc&showProofRead=yes&q[questionTests_testId_eq]=" + resource.id.to_s
end

action_item :show_leaderboard, only: :show do
  link_to 'LeaderBoard', "../../admin/test_leader_boards?order=score_desc&q[testId_eq]=" + resource.id.to_s
end

action_item :update_test_attempts, only: :show do
  link_to 'Update Test Attempts', Rails.configuration.node_site_url + 'api/v1/webhook/updateTestAttempts?testId=' + resource.id.to_s
end

action_item :add_chapter, only: :show do
  link_to 'Add Chapter', '/tests/add_chapter_test/' + resource.id.to_s, target: :_blank
end

action_item :add_question_from_test, only: :show do
  link_to 'Add Questions from Test', '/tests/add_question/' + resource.id.to_s, target: :_blank
end

action_item :add_sequence_of_test_questions, only: :show do
  link_to 'Add Sequence Of Test Questions', '/tests/add_sequence/' + resource.id.to_s, target: :_blank
end

form do |f|
  f.object.positiveMarks = 4
  f.object.negativeMarks = 1
  f.inputs "Test" do
    render partial: 'tinymce'
    f.input :name, hint: "Mention the name of the test here, Eg. Scholarship test 2019"
    f.input :description
    f.input :instructions
    f.input :syllabus
    f.input :durationInMin, label: "Duration in Minutes"
    f.input :free, hint: "Mark checked for Live session test and Scholarship tests"
    f.input :showAnswer, hint: "Mark un-checked only for Scholarship tests"
    f.input :resultMsgHtml, hint: "result message on test result page"
    f.input :negativeMarks, label: "Negative Marks", hint: "No '-' sign is required"
    f.input :positiveMarks, label: "Positive Marks", hint: "No '+' sign is required"
    f.input :numQuestions, label: "Number of Questions"
    f.input :exam, as: :select, :collection => ["AIIMS", "NEET", "AIPMT", "JIPMER"], label: "Exam Type"
    f.input :sections, hint: 'Required format for test sections - [["Physics", 1], ["Chemistry", 20], ["Biology", 40]]'
    f.input :startedAt, as: :datetime_picker, label: "Started Test At"
    f.input :expiryAt, as: :datetime_picker, label: "Expire Test At"
  end

  f.inputs "Additional Information" do
    f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject,  hint: "Select topic (only applicable for live session test)", include_hidden: false, multiple: true
    f.input :ownerType, as: :hidden, :input_html => { :value => 'topic' }
    f.input :courses, as: :select, :collection => Course.public_courses, input_html: { class: "select2" }, include_hidden: false, multiple: true
  end

  f.actions
end

end
