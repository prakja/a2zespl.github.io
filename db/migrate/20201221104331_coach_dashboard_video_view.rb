class CoachDashboardVideoView < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE OR REPLACE VIEW "public"."coach_video_dashboard" AS
    select
      "Video"."id" as id,
      "Video"."name" as video_name,
      "UserVideoStat"."updatedAt" as on_day,
      "Topic"."name" as topic_name,
      "Topic"."id" as topic_id,
      "Subject"."name" as subject_name,
      "Subject"."id" as subject_id,
      "User"."id" as user_id,
      "UserVideoStat"."completed",
      "UserVideoStat"."createdAt",
      "UserVideoStat"."updatedAt",
      "UserVideoStat"."lastPosition" as pos
    FROM 
      "User" 
      INNER JOIN "UserVideoStat" ON "UserVideoStat"."userId" = "User"."id" 
      INNER JOIN "Video" ON "Video"."id" = "UserVideoStat"."videoId" 
      INNER JOIN "ChapterVideo" ON "ChapterVideo"."videoId" = "Video"."id" 
      INNER JOIN "Topic" ON "Topic"."id" = "ChapterVideo"."chapterId" 
      INNER JOIN "Subject" ON "Subject"."id" = "Topic"."subjectId";'
  end
end
