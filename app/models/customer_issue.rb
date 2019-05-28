class CustomerIssue < ApplicationRecord
 self.table_name = "CustomerIssue"

 belongs_to :topic, foreign_key: :topicId, optional: true
 belongs_to :question, foreign_key: :questionId, optional: true
 belongs_to :video, foreign_key: :videoId, optional: true
end
