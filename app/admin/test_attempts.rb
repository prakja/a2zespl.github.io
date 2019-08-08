ActiveAdmin.register TestAttempt do
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
remove_filter :user
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
