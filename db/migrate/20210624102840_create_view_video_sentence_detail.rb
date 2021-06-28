class CreateViewVideoSentenceDetail < ActiveRecord::Migration[5.2]

  def up
    execute 'DROP VIEW IF EXISTS public."VideoSentenceDetail" ;'

    execute '
      CREATE VIEW public."VideoSentenceDetail" AS
        SELECT "VideoSentence".id,
        "VideoSentence".id AS "videoSentenceId",
        "VideoSentence".sentence,
        lead("VideoSentence".sentence, 1) OVER (PARTITION BY "VideoSentence"."videoId" ORDER BY "VideoSentence"."timestampStart") AS "nextSentence",
        lag("VideoSentence".sentence, 1) OVER (PARTITION BY "VideoSentence"."videoId" ORDER BY "VideoSentence"."timestampStart") AS "prevSentence",
        lead("VideoSentence".sentence1, 1) OVER (PARTITION BY "VideoSentence"."videoId" ORDER BY "VideoSentence"."timestampStart") AS "nextSentence1",
        lag("VideoSentence".sentence1, 1) OVER (PARTITION BY "VideoSentence"."videoId" ORDER BY "VideoSentence"."timestampStart") AS "prevSentence1",
        "Video".name AS "videoName"
      FROM public."VideoSentence",
        public."Video" WHERE ("VideoSentence"."videoId" = "Video".id);
    '
  end

  def down
    execute 'DROP VIEW IF EXISTS public."VideoSentenceDetail" ;'
  end
end
