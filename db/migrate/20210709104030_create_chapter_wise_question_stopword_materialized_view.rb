class CreateChapterWiseQuestionStopwordMaterializedView < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    CREATE MATERIALIZED VIEW IF NOT EXISTS "ChapterWiseQuestionStopWord" AS
      SELECT 
        topic_id as "topicId", 
        get_chapter_wise_stopwords_from_question(topic_id) as "questionStopwords"
      FROM 
        (SELECT DISTINCT("chapterId") as topic_id FROM "VideoSentence") AS chapter_wise_data
      with data; 
    SQL
  end

  def down
    execute 'DROP MATERIALIZED VIEW IF EXISTS "ChapterWiseQuestionStopWord";'
  end
end
