ActiveAdmin.register Test do
permit_params :name, :sections, :description, :pdfURL, :resultMsgHtml, :instructions, :syllabus, :durationInMin, :free, :showAnswer, :negativeMarks, :positiveMarks, :numQuestions, :exam, :startedAt, :expiryAt, :reviewAt, :discussionEnd, :ownerType, :ownerId, course_ids: [], topic_ids: []
remove_filter :questions, :test_leader_boards, :versions, :testQuestions, :testCourseTests, :testChapterTests, :test_attempts, :target, :question_ids

filter :id_eq, as: :number, label: "Test ID"
filter :courses, as: :searchable_select, multiple: true, collection: -> {Course.public_courses}, label: "Course"
filter :topics, as: :searchable_select, multiple: true, collection: -> {Topic.name_with_subject}, label: "Topic"

preserve_default_filters!

scope :system_tests, default: true, show_count: false
scope :neet_course, show_count: false
scope :test_series_2018, show_count: false
scope :test_series_2019, show_count: false
scope :test_series_2020, show_count: false

scope :botany, show_count: false
scope :chemistry, show_count: false
scope :physics, show_count: false
scope :zoology, show_count: false
scope :dynamic_tests, show_count: false
scope :all, show_count: false

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
  # column ("All Questions") {|test| link_to 'All Test Questions', "../../admin/questions?order=sequenceId_asc_and_id_asc&showProofRead=yes&q[questionTests_testId_eq]=" + test.id.to_s}
  column ("Add/Delete Questions") {|test| raw('<a target="_blank" href="/tests/crud_question/' + test.id.to_s + '">Add/Delete Questions</a>')}
  column ("Get PDF") {|test| raw('<a target="_blank" href="https://www.neetprep.com/test-question/' + test.id.to_s + '?white&showId=true&orderBy=SEQASC">Get PDF</a>')}
  column ("Get PDF with Solution") {|test| raw('<a target="_blank" href="/questions/test_question_pdf/' + test.id.to_s + '">Get PDF with Solution</a>')}
  column ("Check Translation") {|test| raw('<a target="_blank" href="/questions/test_translation?test=' + test.id.to_s + '">Check Translation</a>')}
  column ("History") {|test| raw('<a target="_blank" href="/admin/tests/' + (test.id).to_s + '/history">View History</a>')}
  actions
end

  # remove one of the duplicate question
  member_action :remove_duplicate, method: :post do
    ActiveRecord::Base.connection.query('delete from "TestQuestion" where "questionId" = ' + params[:delete_question_id] + 'and "testId" in (select "testId" from "TestQuestion" where "questionId" in  (' + params[:delete_question_id] + ', ' + params[:retain_question_id] + ') group by "testId" having count(*) > 1);')
    redirect_to duplicate_questions_admin_test_path(resource), notice: "Duplicate question removed from test questions!"
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
#
# action_item :show_question, only: :show do
#   link_to 'All Test Questions', "../../admin/questions?order=sequenceId_asc_and_id_asc&showProofRead=yes&q[questionTests_testId_eq]=" + resource.id.to_s
# end

action_item :show_leaderboard, only: :show do
  link_to 'LeaderBoard', "../../admin/test_leader_boards?order=score_desc&q[testId_eq]=" + resource.id.to_s
end

action_item :show_attempts, only: :show do
  link_to 'Test Attempts', "../../admin/test_attempts?order=id_desc&q[testId_eq]=" + resource.id.to_s
end

action_item :show_discussions, only: :show do
  link_to 'Discussion', Rails.configuration.node_site_url + 'test-discussion/' + resource.id.to_s
end

action_item :update_test_attempts, only: :show do
  link_to 'Update Test Attempts', Rails.configuration.node_site_url + 'api/v1/webhook/updateTestAttempts?testId=' + resource.id.to_s, method: :post
end

action_item :add_chapter, only: :show do
  link_to 'Add Chapter', '/tests/add_chapter_test/' + resource.id.to_s, target: :_blank
end

action_item :add_question_from_test, only: :show do
  link_to 'Bulk Add Questions from Test', '/tests/add_question/' + resource.id.to_s, target: :_blank
end

action_item :crud_test_questions, only: :show do
  link_to 'Add/Delete/Reorder Questions from Test', '/tests/crud_question/' + resource.id.to_s, target: :_blank
end

action_item :add_sequence_of_test_questions, only: :show do
  link_to 'Add Sequence Of Test Questions', '/tests/add_sequence/' + resource.id.to_s, target: :_blank
end

action_item :two_columns_test_pdf, only: :show do
  link_to 'PDF (Two Columns)', '/tests/questions/' + resource.id.to_s, target: :_blank
end

action_item :questions_list, only: :show do
  link_to 'Questions List', '/admin/questions?order=id_asc&q[tests_id_eq]=' + resource.id.to_s, target: :_blank
end

action_item :duplicate_questions, only: :show do
  link_to 'Duplicate Questions', duplicate_questions_admin_test_path(resource), target: :_blank
end

action_item :show_leaderboard, only: :show do
  link_to 'Scholarship LeaderBoard', resource.id.to_s + "/leader_board"
end

  member_action :duplicate_questions do
    @test = Test.find(resource.id)
    @question_pairs = ActiveRecord::Base.connection.query('Select "Question"."id", "Question"."question", "Question1"."id", "Question1"."question", "Question"."correctOptionIndex", "Question1"."correctOptionIndex", "Question"."options", "Question1".options, "Question"."explanation", "Question1"."explanation" from "TestQuestion" INNER JOIN "Question" ON "Question"."id" = "TestQuestion"."questionId" and "Question"."deleted" = false and "TestQuestion"."testId" = ' + resource.id.to_s + ' INNER JOIN "TestQuestion" AS "TestQuestion1" ON "TestQuestion1"."testId" = "TestQuestion"."testId" and "TestQuestion"."questionId" < "TestQuestion1"."questionId" INNER JOIN "Question" AS "Question1" ON "Question1"."id" = "TestQuestion1"."questionId" and "Question1"."deleted" = false and similarity("Question1"."question", "Question"."question") > 0.7 and "TestQuestion1"."testId" = ' + resource.id.to_s + " limit 5");
  end

form do |f|
  f.object.positiveMarks = 4
  f.object.negativeMarks = 1
  f.inputs "Test" do
    render partial: 'tinymce'
    f.input :name, hint: "Mention the name of the test here, Eg. Scholarship test 2019"
    f.input :description, as: :string
    f.input :instructions, as: :string
    f.input :syllabus
    f.input :durationInMin, label: "Duration in Minutes"
    f.input :free, hint: "Mark checked for Live session test and Scholarship tests"
    f.input :scholarship, hint: "Mark checked only for Scholarship tests"
    f.input :showAnswer, hint: "Uncheck if you don't want student to see test solution after exam"
    f.input :resultMsgHtml, hint: "result message on test result page"
    f.input :negativeMarks, label: "Negative Marks", hint: "No '-' sign is required"
    f.input :positiveMarks, label: "Positive Marks", hint: "No '+' sign is required"
    f.input :numQuestions, label: "Number of Questions"
    f.input :exam, as: :select, :collection => ["AIIMS", "NEET", "AIPMT", "JIPMER"], label: "Exam Type"
    f.input :sections, hint: 'Required format for test sections - [["Biology", 1], ["Chemistry", 91], ["Physics", 136]]'
    f.input :startedAt, as: :datetime_picker, label: "Started Test At"
    f.input :expiryAt, as: :datetime_picker, label: "Expire Test At"
    f.input :reviewAt, as: :datetime_picker, label: "Review Test At"
    f.input :discussionEnd, as: :datetime_picker, label: "Test discussion End At"
    f.input :pdfURL, as: :string
  end

  f.inputs "Additional Information" do
    f.input :topics, input_html: { class: "select2" }, :collection => Topic.name_with_subject,  hint: "Select topic (only applicable for live session test)", multiple: true
    render partial: 'hidden_topic_ids', locals: {topics: f.object.topics}
    f.input :ownerType, as: :hidden, :input_html => { :value => 'topic' }
    f.input :courses, as: :select, :collection => Course.public_courses, input_html: { class: "select2" }, multiple: true
  end

  f.actions
end

controller do
  def leader_board
    @test_id = params[:id]
    test = Test.find(@test_id)
    if params[:last_date].nil?
      @date_time = test&.reviewAt || DateTime.now
      @display_date_time = test&.reviewAt&.strftime("%Y-%m-%dT%H:%M") || DateTime.now.strftime("%Y-%m-%dT%H:%M") 
    else
      @date_time = DateTime.parse(params[:last_date])
      @display_date_time = params[:last_date]
    end
    @paid_attempts = TestAttempt.where(testId: @test_id, completed: true).where('"finishedAt" < ?', @date_time).where(UserCourse.where('"UserCourse"."userId" = "TestAttempt"."userId"').limit(1).arel.exists).order("(\"result\"->>'totalMarks')::INTEGER DESC").limit(40)
    @inspire_attempts = TestAttempt.where(testId: @test_id, completed: true).where('"finishedAt" < ?', @date_time).where(UserCourse.where('"UserCourse"."userId" = "TestAttempt"."userId" and "UserCourse"."courseId" in (' + Rails.configuration.aryan_raj_test_series_2_yr.to_s + ')').limit(1).arel.exists).order("(\"result\"->>'totalMarks')::INTEGER DESC").limit(20)
    @achiever_attempts = TestAttempt.where(testId: @test_id, completed: true).where('"finishedAt" < ?', @date_time).where(UserCourse.where('"UserCourse"."userId" = "TestAttempt"."userId" and "UserCourse"."courseId" in (287)').limit(1).arel.exists).order("(\"result\"->>'totalMarks')::INTEGER DESC").limit(20)
  end
end


end
