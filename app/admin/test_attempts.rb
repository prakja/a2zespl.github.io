ActiveAdmin.register TestAttempt do
  remove_filter :user, :test
  preserve_default_filters!
  filter :testId_eq, as: :number, label: "Test ID"
  filter :userId_eq, as: :number, label: "User ID"
  filter :score_gte, as: :number, label: "Score >="
  filter :score_lt, as: :number, label: "Score <"

  scope :test_series, show_count: false
  scope :aryan_raj_test_series, show_count: false
  controller do
    def scoped_collection
      super.includes(:test, user: :user_profile)
    end
  end

  index do
    id_column
    column :user
    column :test
    column :completed
    column :result
    column "Total" do |testAttempt|
      if testAttempt.result.present? and testAttempt.result['totalMarks'].present?
        testAttempt.result['totalMarks']
      end
    end
    column "Physics Score" do |testAttempt|
      if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][2].present?
        testAttempt.result['sections'][2]['totalMarks']
      end
    end
    column "Chemistry Score" do |testAttempt|
      if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][1].present?
        testAttempt.result['sections'][1]['totalMarks']
      end
    end
    column "Biology Score" do |testAttempt|
      if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][0].present?
        testAttempt.result['sections'][0]['totalMarks']
      end
    end
    column "Time Taken" do |testAttempt|
      if testAttempt.elapsedDurationInSec.present?
        (testAttempt.elapsedDurationInSec / 60.0).round
      end
    end
    column "Time Taken 2" do |testAttempt|
      if testAttempt.createdAt.present? and testAttempt.updatedAt.present?
        raw(((testAttempt.updatedAt - testAttempt.createdAt) / 60).round.to_s + " minutes")
      end
    end
    column ("Link") {|testAttempt| testAttempt.completed ? raw('<a target="_blank" href="https://www.neetprep.com/testResult/' + Base64.encode64("TestAttempt:" + testAttempt.id.to_s) + '">Result Summary</a>') : ''}
    actions
  end

  csv do
    column (:name) do |testAttempt|
      testAttempt.user&.user_profile&.displayName
    end
    column (:email) do |testAttempt|
      testAttempt.user.email || ""
    end
    column (:profile_email) do |testAttempt|
      testAttempt.user.user_profile.nil? ? "" : testAttempt.user.user_profile.email || ''
    end
    column (:phone) do |testAttempt|
      testAttempt.user.phone || ""
    end
    column (:profile_phone) do |testAttempt|
      testAttempt.user.user_profile.nil? ? "" : testAttempt.user.user_profile.phone || ""
    end
    column (:test_name) do |testAttempt|
      testAttempt&.test.name
    end
    column "Total" do |testAttempt|
      if testAttempt.result.present? and testAttempt.result['totalMarks'].present?
        testAttempt.result['totalMarks']
      end
    end
    column "Physics Score" do |testAttempt|
      if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][2].present?
        testAttempt.result['sections'][2]['totalMarks']
      end
    end
    column "Chemistry Score" do |testAttempt|
      if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][1].present?
        testAttempt.result['sections'][1]['totalMarks']
      end
    end
    column "Biology Score" do |testAttempt|
      if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][0].present?
        testAttempt.result['sections'][0]['totalMarks']
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :user
      row :test
      row :testId
      row :elapsedDurationInSec
      row :completed
      row :result
      row "Physics Score" do |testAttempt|
        if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][2].present?
          testAttempt.result['sections'][2]['totalMarks']
        end
      end
      row "Chemistry Score" do |testAttempt|
        if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][1].present?
          testAttempt.result['sections'][1]['totalMarks']
        end
      end
      row "Biology Score" do |testAttempt|
        if testAttempt.result.present? and testAttempt.result['sections'].present? and testAttempt.result['sections'][0].present?
          testAttempt.result['sections'][0]['totalMarks']
        end
      end
      row :createdAt
      row :updatedAt
      row ("Question Answers") { |testAttempt|
        raw("<pre>#{JSON.pretty_generate(testAttempt.userAnswers)}</pre>")
      }
      row (:correctAnswerCount) { |test_attempt|
        raw('<a target="_blank" href=/admin/answers?q[userId_eq]='+test_attempt.userId.to_s+'&scope=correct_answers&q[testAttemptId_eq]=' + test_attempt.id.to_s + '>' + "Correct Answers" + '</a>')
      }
      row (:incorrectAnswerCount) { |test_attempt|
        raw('<a target="_blank" href=/admin/answers?q[userId_eq]='+test_attempt.userId.to_s+'&scope=incorrect_answers&q[testAttemptId_eq]=' + test_attempt.id.to_s + '>' + "Incorrect Answers" + '</a>')
      }
      row ("Question Duration") { |testAttempt|
        raw("<pre>#{JSON.pretty_generate(testAttempt.userQuestionWiseDurationInSec)}</pre>")
      }
      row ("Link") {|testAttempt| testAttempt.completed ? raw('<a target="_blank" href="https://www.neetprep.com/testResult/' + Base64.encode64("TestAttempt:" + testAttempt.id.to_s) + '">Result Summary</a>') : ''}
    end
    active_admin_comments
  end

  action_item :calculate_test_result, only: :show do
    link_to 'Calculate Test Result', Rails.configuration.node_site_url + 'api/v1/webhook/updateTestAttempt?testAttemptId=' + resource.id.to_s, method: :post
  end

  action_item :update_test_answers, only: :show do
    link_to 'Update Test Answers', Rails.configuration.node_site_url + 'api/v1/webhook/updateSingleTestAttemptAnswers?testAttemptId=' + resource.id.to_s, method: :post
  end

end
