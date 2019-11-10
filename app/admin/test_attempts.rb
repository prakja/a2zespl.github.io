ActiveAdmin.register TestAttempt do
  remove_filter :user, :test
  preserve_default_filters!
  filter :testId_eq, as: :number, label: "Test ID"
  filter :userId_eq, as: :number, label: "User ID"
  filter :score_gte, as: :number, label: "Score >="
  filter :score_lt, as: :number, label: "Score <"

  scope :test_series, show_count: false
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
        (elapsedDurationInSec / 60.0).round
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

  show do
    attributes_table do
      row :id
      row :user
      row :test
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
      row ("Link") {|testAttempt| testAttempt.completed ? raw('<a target="_blank" href="https://www.neetprep.com/testResult/' + Base64.encode64("TestAttempt:" + testAttempt.id.to_s) + '">Result Summary</a>') : ''}
    end
    active_admin_comments
  end

end
