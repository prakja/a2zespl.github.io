class BookmarkQuestion < ApplicationRecord
  self.table_name = "BookmarkQuestion"
  
  belongs_to :question, class_name: "Question", foreign_key: 'questionId'
  belongs_to :user, class_name: "User", foreign_key: 'userId' 
end
