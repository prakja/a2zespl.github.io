class CoachDashboardQuestionView < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE OR REPLACE VIEW "public"."coach_question_dashboard" AS
    select
      "Answer"."id" as id,
      "Question"."correctOptionIndex" as correct_option,
      "Question"."id" as question_id,
      "Answer"."createdAt" as on_day,
      "Answer"."userAnswer" as user_answer,
      "Topic"."name" as topic_name,
      "Topic"."id" as topic_id,
      "Subject"."name" as subject_name,
      "Subject"."id" as subject_id,
      "User"."id" as user_id,
      "Answer"."createdAt",
      "Answer"."updatedAt"
    FROM 
      "User" 
      INNER JOIN "Answer" ON "Answer"."userId" = "User"."id" 
      INNER JOIN "Question" ON "Question"."id" = "Answer"."questionId" 
      INNER JOIN "ChapterQuestion" ON "ChapterQuestion"."questionId" = "Question"."id" 
      INNER JOIN "Topic" ON "Topic"."id" = "ChapterQuestion"."chapterId" 
      INNER JOIN "Subject" ON "Subject"."id" = "Topic"."subjectId"
    WHERE
      "Answer"."testAttemptId" IS NULL and
      "Question"."deleted" = false;'
  end
end
