class TopicQuestion < ApplicationRecord
  belongs_to :topic, class_name: "Topic", foreign_key: "topic_id"
  belongs_to :question, class_name: "Question", foreign_key: "question_id"
end
