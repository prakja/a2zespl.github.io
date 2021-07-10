class TopicQuestionStopWord < ApplicationRecord
  self.table_name = :ChapterWiseQuestionStopWord

  default_scope { order(topicId: :asc) }

  belongs_to :topic, class_name: :Topic, foreign_key: :topicId

  def stopwords
    self.questionStopwords["stopwords"]
  end

  def singular_stopwords
    stopwords.map { |w| w.singularize.downcase }.uniq
  end

  def stopword_count
    self.questionStopwords["word_count"]
  end
end
