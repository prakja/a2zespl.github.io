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
    column :userAnswer
    column :mistake
    column :action
    column :subTopicName
    column :chapterName
    column :subjectName
  end
  
end
