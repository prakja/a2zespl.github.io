ActiveAdmin.register TestAttempt do
  index do
    id_column
    column :userId
    column :testId
    column :elapsedDurationInSec
    column :currentQuestionOffset
    column :completed
    column :userAnswers
    column :userQuestionWiseDurationInSec
    column :result
    column :createdAt
    column :updatedAt
    column :visitedQuestions
    column :markedQuestions
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
    actions
  end

end
