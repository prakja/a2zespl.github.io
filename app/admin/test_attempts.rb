ActiveAdmin.register TestAttempt do
  remove_filter :user, :test
  preserve_default_filters!
  filter :testId_eq, as: :number, label: "Test ID"
  filter :userId_eq, as: :number, label: "User ID"
  index do
    id_column
    column :user
    column :test
    column :elapsedDurationInSec
    column :completed
    column :result
    column "Physics Score" do |testAttempt|
      if testAttempt.result
        if testAttempt.result['sections']
          testAttempt.result['sections'][2]['totalMarks']
        end
      end
    end
    column "Chemistry Score" do |testAttempt|
      if testAttempt.result
        if testAttempt.result['sections']
          testAttempt.result['sections'][1]['totalMarks']
        end
      end
    end
    column "Biology Score" do |testAttempt|
      if testAttempt.result
        if testAttempt.result['sections']
          testAttempt.result['sections'][0]['totalMarks']
        end
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
        if testAttempt.result
          if testAttempt.result['sections']
            testAttempt.result['sections'][2]['totalMarks']
          end
        end
      end
      row "Chemistry Score" do |testAttempt|
        if testAttempt.result
          if testAttempt.result['sections']
            testAttempt.result['sections'][1]['totalMarks']
          end
        end
      end
      row "Biology Score" do |testAttempt|
        if testAttempt.result
          if testAttempt.result['sections']
            testAttempt.result['sections'][0]['totalMarks']
          end
        end
      end
      row ("Link") {|testAttempt| testAttempt.completed ? raw('<a target="_blank" href="https://www.neetprep.com/testResult/' + Base64.encode64("TestAttempt:" + testAttempt.id.to_s) + '">Result Summary</a>') : ''}
    end
    active_admin_comments
  end

end
