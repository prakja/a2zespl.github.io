class CreateViewTestAnalytics < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE OR REPLACE VIEW "public"."test_attempt_questions" AS
    select
      ROW_NUMBER() over(PARTITION BY "TestAttempt"."id" ORDER BY "TestQuestion"."seqNum" ASC, "Question"."id" ASC ) as "id",
      "TestAttempt"."testId",
      "TestAttempt"."id" as "attemptId",
      "TestAttempt"."userId",
      "Answer"."userAnswer",
      "TestAttemptPostmartem"."mistake",
      "TestAttemptPostmartem"."action",
      "SubTopic1"."name" as "subTopicName",
      "Topic"."name" as "chapterName",
      "Subject"."name" as "subjectName"
      FROM 
      "TestAttempt" JOIN "Test" ON "Test"."id" = "TestAttempt"."testId" AND "TestAttempt"."completed" = TRUE
      JOIN "TestQuestion" ON "TestQuestion"."testId" = "Test"."id"
      JOIN "Question" ON "Question"."id" = "TestQuestion"."questionId"
      LEFT OUTER JOIN "Answer" ON "TestAttempt"."id" = "Answer"."testAttemptId" AND "Answer"."questionId" = "Question"."id"
      LEFT OUTER JOIN "TestAttemptPostmartem" ON "TestAttemptPostmartem"."testAttemptId" = "TestAttempt"."id"
      LEFT OUTER JOIN LATERAL (SELECT "SubTopic"."name" AS "name" FROM "QuestionSubTopic", "SubTopic" WHERE "QuestionSubTopic"."questionId" = "Question"."id" AND "QuestionSubTopic"."subTopicId" = "SubTopic"."id" FETCH FIRST 1 ROW ONLY) AS "SubTopic1" ON TRUE
      LEFT OUTER JOIN "Topic" ON "Topic"."id" = "Question"."topicId"
      LEFT OUTER JOIN "Subject" ON "Subject"."id" = "Question"."subjectId";'
  end
end
