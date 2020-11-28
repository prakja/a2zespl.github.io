ActiveAdmin.register TestAttemptQuestion do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :testId, :attemptId, :userId, :userAnswer, :mistake, :action, :subTopicName, :chapterName, :subjectName
  #
  # or
  #
  # permit_params do
  #   permitted = [:testId, :attemptId, :userId, :userAnswer, :mistake, :action, :subTopicName, :chapterName, :subjectName]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  csv do
    # column ("userAnswer") { |attempt|
    #   attempt.userAnswer
    # }
    column ("userAnswer") { |attempt|
      if attempt.isCorrect
        "Correct"
      else
        "Incorrect"
      end
    }
    column ("test") { |attempt|
      Test.find(attempt.testId).name
    }
    column ("mistake") { |attempt|
      mistake_value = {
        "1" => "Silly Mistake (incorrect)",
        "2" => "Conceptual Mistake (incorrect)",
        "3" => "Made a Guess",
        "4" => "Conceptual Mistake (not attempted)",
        "5" => "Time Management (not attempted)",
        "6" => "Not Studied or Forgotten (not attempted)",
      }
      mistake_value[attempt.mistake.to_s] || attempt.mistake
    }
    column ("action") { |attempt|
      action_value = {
        "1" => "I will revise topic",
        "2" => "I will practice more questions",
        "3" => "I will improve speed",
        "4" => "I will understand concept",
      }
      action_value[attempt.action.to_s] || attempt.action
    }
    column :subTopicName
    column :chapterName
    column :subjectName
  end
  
end
