class CreateViewChapterSubtopicWeightage < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE VIEW "ChapterSubTopicWeightage" AS 
    SELECT 
      "SubTopic"."id" as "subTopicId", 
      "SubTopic"."name" as "subTopicName",
      "SubTopic"."topicId" as "chapterId",
      count(distinct("Question"."id")) as "ncertQuestionCount", 
      sum(count(distinct("Question"."id"))) OVER (PARTITION by "SubTopic"."topicId") as "chapterCount", 
      count(distinct("Question"."id")) / sum(count(distinct("Question"."id"))) OVER (PARTITION by "SubTopic"."topicId") as "weightage"
    FROM "CourseChapter", "Question", "QuestionSubTopic", "SubTopic"
    WHERE "QuestionSubTopic"."subTopicId" = "SubTopic"."id"
      AND "CourseChapter"."chapterId" = "SubTopic"."topicId"
      AND "CourseChapter"."courseId" = 8
      AND "SubTopic"."videoOnly" = false
      AND "Question"."id" = "QuestionSubTopic"."questionId"
      AND "Question"."deleted" = false
      AND "SubTopic"."deleted" = false
      AND "Question"."ncert" = true
    GROUP BY "SubTopic"."id", "SubTopic"."topicId";'
  end

  def down
    execute 'DROP VIEW "ChapterSubTopicWeightage"'
  end
end

