SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: google_ads; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA google_ads;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: enum_Advertisement_platform; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Advertisement_platform" AS ENUM (
    'website',
    'mobile',
    'both'
);


--
-- Name: enum_Coupon_discountType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Coupon_discountType" AS ENUM (
    'percentage',
    'absolute'
);


--
-- Name: enum_CourseInvitation_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_CourseInvitation_role" AS ENUM (
    'courseStudent',
    'courseManager',
    'courseCreator',
    'courseAdmin'
);


--
-- Name: enum_Course_package; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Course_package" AS ENUM (
    'k12',
    'iit',
    'neet',
    'bionks',
    'iitpariksha',
    'neetpariksha'
);


--
-- Name: enum_Doubt_doubtType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Doubt_doubtType" AS ENUM (
    'Content_Issue',
    'Wrong_Answer',
    'Wrong_Explanation',
    'Insufficient_Explanation',
    'Problem_With_Playback',
    'Wrong_Question',
    'Question_Not_Related_To_Topic',
    'Spelling_Mistakes',
    'Academic_Doubt',
    'Website_Not_Working_Properly',
    'Wrong_Ncert_Sentence_Marking',
    'Wrong_Video_Sentence_Marking'
);


--
-- Name: enum_Message_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Message_type" AS ENUM (
    'normal',
    'joinChat',
    'leftChat',
    'analytics',
    'pdf',
    'question'
);


--
-- Name: enum_Ncert_question_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Ncert_question_type" AS ENUM (
    'Solved_Example',
    'Exercises',
    'In-Text_Questions',
    'Exampler_Question'
);


--
-- Name: enum_Payment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Payment_status" AS ENUM (
    'created',
    'requestSent',
    'responseReceivedSuccess',
    'responseReceivedFailure'
);


--
-- Name: enum_Question_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Question_level" AS ENUM (
    'BASIC-NCERT',
    'MASTER-NCERT'
);


--
-- Name: enum_Question_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Question_type" AS ENUM (
    'MCQ-SO',
    'MCQ-AR',
    'MCQ-MO',
    'SUBJECTIVE'
);


--
-- Name: enum_SOS_gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_SOS_gender" AS ENUM (
    'Male',
    'Female'
);


--
-- Name: enum_Test_exam; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Test_exam" AS ENUM (
    'AIIMS',
    'NEET',
    'AIPMT',
    'JIPMER'
);


--
-- Name: enum_UserCourse_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_UserCourse_role" AS ENUM (
    'courseStudent',
    'courseManager',
    'courseCreator',
    'courseAdmin'
);


--
-- Name: enum_UserProfile_gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_UserProfile_gender" AS ENUM (
    'Male',
    'Female'
);


--
-- Name: jwt_token; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.jwt_token AS (
	role text,
	userid integer
);


--
-- Name: AddCourseOfferForShortDurationCourse(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."AddCourseOfferForShortDurationCourse"() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
   t_row RECORD;
BEGIN
for t_row in
  select "Payment"."userId", "amount", "User"."email", "User"."phone"
  from "Payment"
  join "User" on "User"."id" = "Payment"."userId"
  join "UserCourse" on "UserCourse"."id" = "Payment"."purchasedItemId"
  where "Payment"."createdAt" > '2020-06-18' 
  and "Payment"."response" is not null 
  and "Payment"."paymentForId" in (287, 255, 38, 43, 44, 45, 53, 55, 57, 58, 59, 60, 62, 63)
  and "Payment"."status"='responseReceivedSuccess'
  and "UserCourse"."courseId" != 8 and "UserCourse"."expiryAt" > current_timestamp
  and "User"."email" is null loop
    insert into 
    "CourseOffer"("email", "phone", "title", "description", "courseId", "fee", "discountedFee", "expiryAt", "offerStartedAt", "offerExpiryAt") 
    values(coalesce("t_row"."email", ''), coalesce("t_row"."phone", ''), 'Title', '<p class="course-offer-discount">Discount Based on your previous purchases</p>', 29, 12999, 5999-"t_row"."amount", '2021-06-30', current_timestamp, '2021-01-31') ON CONFLICT ON CONSTRAINT single_applicable_course_offer do update set "discountedFee" = case when "CourseOffer"."discountedFee"-"t_row"."amount" > 0 then "CourseOffer"."discountedFee"-"t_row"."amount" else 0 end;
end loop;
END
$$;


--
-- Name: CreateCourseAccessForZeroFee(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."CreateCourseAccessForZeroFee"() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
   t_row RECORD;
BEGIN
for t_row in
  SELECT "CourseOffer".* 
  FROM "CourseOffer" 
  WHERE "CourseOffer"."accepted" = false 
  AND "CourseOffer"."hidden" = false  
  AND ("email" is not null) 
  AND ("courseId" = 29)
  AND ("discountedFee" = 0)
  AND ("offerExpiryAt" > current_timestamp) 
  AND ("offerStartedAt" < current_timestamp) 
  and ("phone" is not null) 
  AND ("offerExpiryAt" > current_timestamp) 
  AND ("offerStartedAt" < current_timestamp) loop
    with user_row as (select * from "User" where "email" = "t_row"."email")
    INSERT INTO public."UserCourse"
("startedAt", "expiryAt", "role", "courseId", "userId", "couponId", trial, "invitationId", "courseOfferId")
select current_timestamp, "t_row"."expiryAt", 'courseStudent', "t_row"."courseId", user_row."id", NULL, true, NULL, "t_row"."id"
 from user_row;
 update "CourseOffer" set "accepted"=true where "id"="t_row"."id";
end loop;
END
$$;


--
-- Name: InsertSelectQuestions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."InsertSelectQuestions"(chapterid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  insert into "ChapterQuestion" ("chapterId", "questionId") select (select "dupId" from "DuplicateChapter", "SubjectChapter" where "origId" = chapterId and "SubjectChapter"."chapterId" = "DuplicateChapter"."dupId" and "SubjectChapter"."subjectId" = 727), "id" from "Question" where "id" in (select "questionId" from "ChapterQuestion" where "chapterId" = chapterId) and "deleted" = false and "explanation" ilike '%page%';
END
$$;


--
-- Name: LongRunningQueries(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."LongRunningQueries"(minutes integer DEFAULT 1) RETURNS TABLE(processid integer, dur interval, q text, s text)
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN QUERY SELECT
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
  FROM pg_stat_activity
  WHERE (now() - pg_stat_activity.query_start) > (minutes || 'minutes')::INTERVAL;
  END
  $$;


--
-- Name: MissingNEETExamQuestion(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."MissingNEETExamQuestion"(yr integer) RETURNS TABLE("qId" integer)
    LANGUAGE plpgsql
    AS $$
  BEGIN
  RETURN QUERY SELECT "questionId" From (
      select * From (
        select "CourseTestQuestion"."questionId" from "CourseTestQuestion", "Test" where "courseId" = 980 and "Test"."id" = "CourseTestQuestion"."testId" and extract(year from "startedAt") = yr
        except
        select "CourseQuestion"."questionId" from "CourseQuestion", "Question" where "courseId" = 8 and "CourseQuestion"."questionId" = "Question"."id" and exists (select * from "QuestionDetail" where "QuestionDetail"."questionId" = "Question"."id" and "exam" in ('NEET', 'AIPMT') and "year" = yr)) a
        except 
       select "DuplicateQuestion"."questionId2" from "CourseQuestion", "Question", "DuplicateQuestion" where "CourseQuestion"."courseId" = 8 and "questionId" = "Question"."id" and exists (select * from "QuestionDetail" where "QuestionDetail"."questionId" = "Question"."id" and "exam" in ('NEET', 'AIPMT') and "year" = yr) and "DuplicateQuestion"."questionId1" = "Question"."id") b
       except 
      select "DuplicateQuestion"."questionId1" as "questionId" from "CourseQuestion", "Question", "DuplicateQuestion" where "CourseQuestion"."courseId" = 8 and "questionId" = "Question"."id" and exists (select * from "QuestionDetail" where "QuestionDetail"."questionId" = "Question"."id" and "exam" in ('NEET', 'AIPMT') and "year" >= yr) and "DuplicateQuestion"."questionId2" = "Question"."id";
  END
  $$;


--
-- Name: PopulateDailyUserCourseEvent(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."PopulateDailyUserCourseEvent"(days integer DEFAULT 1, courseid integer DEFAULT 255) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    maxDate DATE;
BEGIN
  select max("eventDate") from "DailyUserEvent" where "courseId" = courseId into maxDate;
  insert into "DailyUserEvent" ("userId", "event", "eventDate", "eventCount", "courseId") select "userId", 'Question', date("createdAt"), count(*), courseId from "Answer", "QuestionCourse"
    where "createdAt" >= maxDate + 1 and "createdAt" < maxDate + 1 + days
    and "QuestionCourse"."courseId" = courseId
    and "QuestionCourse"."questionId" = "Answer"."questionId"
    group by "userId", date("createdAt");
END
$$;


--
-- Name: PopulateDailyUserEvent(integer, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."PopulateDailyUserEvent"(days integer DEFAULT 1, startdate date DEFAULT '2020-01-01'::date) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    maxDate DATE;
BEGIN
  SELECT max("eventDate") from "DailyUserEvent" into maxDate;
  if maxDate is not null then
    startDate := maxDate + 1;
  end if;
  insert into "DailyUserEvent" ("userId", "event", "eventDate", "eventCount") select "userId", 'Question', date("createdAt"), count(*) from "Answer" 
    where "createdAt" >= startDate and "createdAt" < startDate + days
    group by "userId", date("createdAt");
END
$$;


--
-- Name: SetChapterFlashCardSeq(boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."SetChapterFlashCardSeq"(forcerefresh boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF forceRefresh THEN 
    UPDATE "ChapterFlashCard" c
      SET "seqId" = c2.seqnum
      FROM (SELECT c2."id", row_number() over (PARTITION BY "chapterId" ORDER BY "flashCardId") as seqnum
            from "ChapterFlashCard" c2
           ) c2
      WHERE c2."id" = c."id";
  ELSE 
    UPDATE "ChapterFlashCard" c
      SET "seqId" = c2.seqnum
      FROM (SELECT c2."id", row_number() over (PARTITION BY "chapterId" ORDER BY "flashCardId") as seqnum
            from "ChapterFlashCard" c2
           ) c2
      WHERE c2."id" = c."id" and c."seqId" is null;
   END IF;
END
$$;


--
-- Name: SetChapterFlashCardSeq(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."SetChapterFlashCardSeq"(chapterid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE "ChapterFlashCard" c
    SET "seqId" = c2.seqnum
    FROM (SELECT c2."id", row_number() over (order by "flashCardId") as seqnum
          from "ChapterFlashCard" c2 where "chapterId" = chapterid
         ) c2
    WHERE c2."id" = c."id";
END
$$;


--
-- Name: SyncChapterQuestions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."SyncChapterQuestions"(chapterid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  insert into "ChapterQuestion" ("chapterId", "questionId") 
    select "DuplicateChapter"."dupId", "ChapterQuestion"."questionId" 
      from "ChapterQuestion", "DuplicateChapter", "SubjectChapter", "Subject"
      where "ChapterQuestion"."chapterId" = "DuplicateChapter"."origId"
        and "SubjectChapter"."chapterId" = "ChapterQuestion"."chapterId" 
        and "SubjectChapter"."subjectId" = "Subject"."id"
        and "Subject"."courseId" = 8
        and "DuplicateChapter"."dupId" = chapterId
    EXCEPT 
    select "ChapterQuestion"."chapterId", "ChapterQuestion"."questionId"
      from "ChapterQuestion" 
      where "ChapterQuestion"."chapterId" = chapterId;
  
  Delete from "ChapterQuestion" where "chapterId" = chapterId and "questionId" in (select "questionId" from 
  (select "ChapterQuestion"."chapterId", "ChapterQuestion"."questionId"
    from "ChapterQuestion" 
    where "ChapterQuestion"."chapterId" = chapterId
      and EXISTS (select 1 from "DuplicateChapter" where "dupId" = chapterId)
  EXCEPT 
  select "DuplicateChapter"."dupId", "ChapterQuestion"."questionId" 
    from "ChapterQuestion", "DuplicateChapter", "SubjectChapter", "Subject"
    where "ChapterQuestion"."chapterId" = "DuplicateChapter"."origId"
    and "SubjectChapter"."chapterId" = "ChapterQuestion"."chapterId" 
    and "SubjectChapter"."subjectId" = "Subject"."id"
    and "Subject"."courseId" = 8
    and "DuplicateChapter"."dupId" = chapterId) deleteQuestions);
END
$$;


--
-- Name: SyncCourseQuestions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."SyncCourseQuestions"(courseid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
  rec RECORD;
BEGIN 
  FOR rec IN 
    SELECT "chapterId" from "SubjectChapter", "Subject" 
      where "SubjectChapter"."subjectId" = "Subject"."id"
        and "Subject"."courseId" = courseId
  LOOP
    PERFORM "SyncChapterQuestions"(rec."chapterId");
  END LOOP;
END
$$;


--
-- Name: SyncSubjectQuestions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."SyncSubjectQuestions"(subjectid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
  rec RECORD;
BEGIN 
  FOR rec IN 
    SELECT "chapterId" from "SubjectChapter", "Subject" 
      where "SubjectChapter"."subjectId" = "Subject"."id"
        and "Subject"."id" = subjectid
  LOOP
    PERFORM "SyncChapterQuestions"(rec."chapterId");
  END LOOP;
END
$$;


--
-- Name: TestAttemptDetailFunc(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."TestAttemptDetailFunc"(usertestattemptid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    test record;
    testId INTEGER := 0;
    showAnswer BOOLEAN := FALSE;
BEGIN
  SELECT "testId" from "TestAttempt" where "id" = userTestAttemptId into testId;
  select "id", "free", "userId", "showAnswer","reviewAt" from "Test" where "id" = testId  INTO test;
  if test."showAnswer" = false then
    return false;
  end if;
  if test."reviewAt" is not null and test."reviewAt" > current_timestamp then
    return false;
  end if;
  if test."free" = true and test."userId" is null then
    return true;
  end if;
  if test."userId" is not null then
     select count("UserCourse"."id") > 0 from "UserCourse" where "UserCourse"."userId" = test."userId" and "UserCourse"."expiryAt" > now() and "UserCourse"."courseId" in (select cast(jsonb_array_elements("value") as integer) from "Constant" where "key" = 'TARGET_BASED_COURSE_IDS') into showAnswer;
     return showAnswer;
  end if;
  if (select count("CourseTest"."id") from "CourseTest" where "testId" = test."id") > 0 then
    SELECT count("UserCourse".id) > 0 FROM "TestAttempt"
     JOIN "Test" ON "Test".id = "TestAttempt"."testId" and "TestAttempt"."id" = userTestAttemptId AND "TestAttempt"."completed" = true
     LEFT JOIN "CourseTest" ON "CourseTest"."testId" = "Test".id AND "Test".free = false
     LEFT JOIN "UserCourse" ON "UserCourse"."userId" = "TestAttempt"."userId" AND "UserCourse"."expiryAt" > now() AND "UserCourse"."courseId" = "CourseTest"."courseId" into showAnswer;
     return showAnswer;
  end if;
SELECT count(UserChapter.id) > 0
     FROM "TestAttempt"
     JOIN "Test" ON "Test".id = "TestAttempt"."testId" and "TestAttempt"."id" = userTestAttemptId AND "TestAttempt"."completed" = true
     LEFT JOIN "ChapterTest" ON "ChapterTest"."testId" = "Test".id AND "Test".free = false
     LEFT JOIN (SELECT 1 as "id", "User".id AS "userId",
            "Topic".id AS "chapterId",
            "Subject".id AS "subjectId"
           FROM "User",
            "UserCourse",
            "Subject",
            "Topic",
            "SubjectChapter"
          WHERE "User".id = "UserCourse"."userId" AND "UserCourse"."courseId" = "Subject"."courseId" AND "Subject".id = "SubjectChapter"."subjectId" AND "SubjectChapter"."chapterId" = "Topic".id AND "UserCourse"."expiryAt" >= now() AND "SubjectChapter".deleted = false) UserChapter ON UserChapter."chapterId" = "ChapterTest"."chapterId" AND (UserChapter."userId" = "TestAttempt"."userId")
  GROUP BY "TestAttempt".id into showAnswer;
return showAnswer;
END
$$;


--
-- Name: _final_median(numeric[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._final_median(numeric[]) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
   SELECT AVG(val)
   FROM (
     SELECT val
     FROM unnest($1) val
     ORDER BY 1
     LIMIT  2 - MOD(array_upper($1, 1), 2)
     OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
   ) sub;
$_$;


--
-- Name: compute_similarity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.compute_similarity() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    select similarity((select "question" from "Question" where "id" = NEW."questionId1"), (select "question" from "Question" where "id" = NEW."questionId2")) into NEW."similarity";
    RETURN NEW;
END
$$;


--
-- Name: duplicateChapterQuestions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."duplicateChapterQuestions"(chapterid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
  rec RECORD;
BEGIN 
  FOR rec IN 
    SELECT "questionId" from "ChapterQuestion"
        where "ChapterQuestion"."chapterId" = chapterId
  LOOP
    PERFORM "duplicateChapterQuestions"(rec."questionId", chapterId);
  END LOOP;
END
$$;


--
-- Name: duplicateChapterQuestions(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."duplicateChapterQuestions"(questionid integer, chapterid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  with asQuestion as (insert into "Question" ("question","explanation","options","correctOptionIndex","type","deleted","paidAccess","level","sequenceId","orignalQuestionId","topicId","subjectId","createdAt","updatedAt") select "question","explanation","options","correctOptionIndex","type","deleted","paidAccess","level","sequenceId","id","topicId","subjectId",current_timestamp,current_timestamp from "Question" where "id"= questionId RETURNING id) update "ChapterQuestion" set "questionId"=(select id from asQuestion) where "chapterId"=chapterId and "questionId"=questionId;
END
$$;


--
-- Name: get_chapter_wise_stopwords_from_question(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_chapter_wise_stopwords_from_question(topic_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$ 
        DECLARE stopword_list TEXT[];
        BEGIN
          RETURN (
            SELECT
              row_to_json(u) AS stopword_list 
            FROM
              (
                SELECT
                  ARRAY_AGG(word) AS stopwords,
                  COUNT(word) AS word_count 
                FROM
                  (
                    SELECT
                      *,
                      ((CAST(ndoc AS decimal) / (
                        SELECT
                          COUNT(id) 
                        FROM
                          "Question" 
                        WHERE
                          "topicId" = topic_id 
                          AND "deleted" = false)) * 100
                      )
                      ::FLOAT AS repr 
                    FROM
                      ts_stat(format('SELECT to_tsvector(''context_dict'', question) FROM "Question" WHERE "topicId" = %s', topic_id)) 
                    WHERE
                      LENGTH(word) > 3 
                    ORDER BY
                      repr DESC 
                  )
                  question_stat 
                WHERE
                  repr >= 7
              )
              u);
        END;
        $$;


--
-- Name: get_g_test_matrix(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_g_test_matrix(question_a_id integer, question_b_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$ 
      DECLARE g_matrix JSON;
      BEGIN
        WITH all_question_attempts AS (select "Answer"."id" as id,
          "Question"."id" as question_id,
            "Answer"."userId" as user_id,
            "Answer"."userAnswer" = "Question"."correctOptionIndex"  as is_correct
        from "Answer" 
        inner join "Question" on 
            "Question"."id" = "Answer"."questionId" 
          where 
            "Question"."id" IN (question_a_id, question_b_id)
      ), both_attempt_records AS (
      select 
          distinct on (a.user_id, a.question_id, b.question_id)
          a.question_id as first_question_id,
          a.is_correct as is_first_question_correct,
          b.is_correct as is_second_question_correct
      from 
        all_question_attempts a 
      cross join all_question_attempts b 
      where
        (a.question_id = question_a_id AND b.question_id = question_b_id) and (a.user_id = b.user_id)
    )

	select row_to_json(u) into g_matrix from (select 
		coalesce(
      sum(
        case 
          when is_first_question_correct = true 
          then 1 
          else 0 
        end), 0) as a_correct,
    coalesce(
      sum(
          case 
            when is_first_question_correct = true and is_second_question_correct = true then 1
            else 0
          end
        ), 0) as both_correct,
    coalesce(sum(
        case
          when is_first_question_correct = true and is_second_question_correct = false then 1
          else 0
        end
    ), 0) as only_a_correct_b_incorrect,
    coalesce(sum(
        case
          when is_second_question_correct = true then 1
          else 0
        end
    ), 0) as b_correct,
    coalesce(
      sum(
        case when is_first_question_correct = false and is_second_question_correct = true then 1 
        else 0 
        end
      ), 0) as only_b_correct_a_incorrect,
    coalesce(sum(case when is_first_question_correct = false then 1 else 0 end), 0) as a_incorrect,
    coalesce(sum(case when is_second_question_correct = false then 1 else 0 end), 0) as b_incorrect,
    coalesce(sum(case when is_first_question_correct = false and is_second_question_correct = false then 1 else 0 end), 0) as both_incorrect
    
	from 
		both_attempt_records) u;
    return g_matrix;
  END;
  $$;


--
-- Name: history_delete(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.history_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO history(event_time, executed_by, origin_value)
     VALUES(CURRENT_TIMESTAMP, SESSION_USER, row_to_json(OLD)::jsonb);
  RETURN NEW;
END;
$$;


--
-- Name: history_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.history_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO history(event_time, executed_by, new_value)
     VALUES(CURRENT_TIMESTAMP, SESSION_USER, row_to_json(NEW)::jsonb);
  RETURN NEW;
END;
$$;


--
-- Name: history_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.history_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  js_new jsonb := row_to_json(NEW)::jsonb;
  js_old jsonb := row_to_json(OLD)::jsonb;
BEGIN
  INSERT INTO history(event_time, executed_by, origin_value, new_value)
     VALUES(CURRENT_TIMESTAMP, SESSION_USER, js_old - js_new, js_new - js_old);
  RETURN NEW;
END;
$$;


--
-- Name: jsonb_delete_left(jsonb, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_delete_left(a jsonb, b text[]) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
    SELECT COALESCE(     
        (
            SELECT ('{' || string_agg(to_json(key) || ':' || value, ',') || '}')
            FROM jsonb_each(a)
            WHERE key <> ALL(b)
        )
    , '{}')::jsonb;
$$;


--
-- Name: FUNCTION jsonb_delete_left(a jsonb, b text[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.jsonb_delete_left(a jsonb, b text[]) IS 'delete keys in second argument from first argument';


--
-- Name: jsonb_delete_left(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_delete_left(a jsonb, b jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
    SELECT COALESCE(     
        (
            SELECT ('{' || string_agg(to_json(key) || ':' || value, ',') || '}')
            FROM jsonb_each(a)
            WHERE NOT ('{' || to_json(key) || ':' || value || '}')::jsonb <@ b
        )
    , '{}')::jsonb;
$$;


--
-- Name: FUNCTION jsonb_delete_left(a jsonb, b jsonb); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.jsonb_delete_left(a jsonb, b jsonb) IS 'delete matching pairs in second argument from first argument';


--
-- Name: jsonb_delete_left(jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_delete_left(a jsonb, b text) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
    SELECT COALESCE(     
        (
            SELECT ('{' || string_agg(to_json(key) || ':' || value, ',') || '}')
            FROM jsonb_each(a)
            WHERE key <> b
        )
    , '{}')::jsonb;
$$;


--
-- Name: FUNCTION jsonb_delete_left(a jsonb, b text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.jsonb_delete_left(a jsonb, b text) IS 'delete key in second argument from first argument';


--
-- Name: newDuplicateChapter(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."newDuplicateChapter"("oldDuplicateChapter" integer, "newOriginalChapter" integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE "returnId" integer; 
BEGIN
Select "NewDuplicateChapter"."dupId" FROM "DuplicateChapter", "DuplicateChapter" as "NewDuplicateChapter", "Topic", "Topic" as "NewTopic", "Subject", "Subject" as "NewSubject"
where "Topic"."subjectId" = "Subject"."id"
and "NewTopic"."subjectId" = "NewSubject"."id"
and "Subject"."courseId" = "NewSubject"."courseId"
and "NewDuplicateChapter"."origId" = "newOriginalChapter"
and "DuplicateChapter"."dupId" = "oldDuplicateChapter"
and "DuplicateChapter"."dupId" = "Topic"."id"
and "NewDuplicateChapter"."dupId" = "NewTopic"."id" into "returnId";
return "returnId";
END
$$;


--
-- Name: rand(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rand() RETURNS double precision
    LANGUAGE sql
    AS $$SELECT random();$$;


--
-- Name: substring_index(text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.substring_index(text, text, integer) RETURNS text
    LANGUAGE sql
    AS $_$SELECT array_to_string((string_to_array($1, $2)) [1:$3], $2);$_$;


--
-- Name: test_attempt_history_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.test_attempt_history_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
  changedAnswers jsonb := NEW."userAnswers"::jsonb - OLD."userAnswers"::jsonb;
BEGIN
  IF changedAnswers::text != '{}' THEN
    INSERT INTO "TestAttemptHistory"("eventTime", "userId", "testId", "changedAnswers")
      VALUES(CURRENT_TIMESTAMP, NEW."userId", NEW."testId", changedAnswers);
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: updateCourseLiveSessionQuestionExplanation(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."updateCourseLiveSessionQuestionExplanation"(courseid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN 
    SELECT "ChapterTest"."testId" from "ChapterTest", "SubjectChapter", "Subject" 
      where "SubjectChapter"."subjectId" = "Subject"."id"
        and "ChapterTest"."chapterId" = "SubjectChapter"."chapterId"
        and "Subject"."courseId" = courseId
  LOOP
    PERFORM "updateLiveSessionQuestionExplanation"(rec."testId");
  END LOOP;   
END
$$;


--
-- Name: updateLiveSessionQuestionExplanation(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."updateLiveSessionQuestionExplanation"(testid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
Update "Question" set "explanation" = concat ("explanation", '<p>Question No: <b>', c."rowNum", '</b> from Live Session Link Below</p>', "Test"."resultMsgHtml") from "TestQuestion", "Test", (select "questionId", row_number() over (order by "TestQuestion"."questionId" asc) as "rowNum" from "TestQuestion" where "testId" = testId) as c where "testId" = testId and "Test"."id" = "TestQuestion"."testId" and "Question"."id" = "TestQuestion"."questionId" and c."questionId" = "Question"."id" and ("Question"."explanation" is null or "Question"."explanation" = '') and "resultMsgHtml" like '%youtu%';   
END
$$;


--
-- Name: updateQuestionSubjectId(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."updateQuestionSubjectId"() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE "Question" set "subjectId" = "SubjectChapter"."subjectId" from "SubjectChapter" where "SubjectChapter"."chapterId" = "Question"."topicId" and "SubjectChapter"."subjectId" in (53,54,55,56) and "Question"."subjectId" is null ;
END
$$;


--
-- Name: median(numeric); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.median(numeric) (
    SFUNC = array_append,
    STYPE = numeric[],
    INITCOND = '{}',
    FINALFUNC = public._final_median
);


--
-- Name: -; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.- (
    FUNCTION = public.jsonb_delete_left,
    LEFTARG = jsonb,
    RIGHTARG = text
);


--
-- Name: -; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.- (
    FUNCTION = public.jsonb_delete_left,
    LEFTARG = jsonb,
    RIGHTARG = text[]
);


--
-- Name: -; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.- (
    FUNCTION = public.jsonb_delete_left,
    LEFTARG = jsonb,
    RIGHTARG = jsonb
);


--
-- Name: OPERATOR - (jsonb, jsonb); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.- (jsonb, jsonb) IS 'delete matching pairs from left operand';


--
-- Name: context_dict; Type: TEXT SEARCH DICTIONARY; Schema: public; Owner: -
--

CREATE TEXT SEARCH DICTIONARY public.context_dict (
    TEMPLATE = pg_catalog.simple,
    stopwords = 'english' );


--
-- Name: context_dict; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.context_dict (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR asciiword WITH public.context_dict;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR word WITH public.context_dict;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR hword_part WITH public.context_dict;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR hword_asciipart WITH public.context_dict;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR asciihword WITH public.context_dict;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR hword WITH public.context_dict;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.context_dict
    ADD MAPPING FOR uint WITH simple;


SET default_tablespace = '';

--
-- Name: CAMPAIGN_PERFORMANCE_REPORT; Type: TABLE; Schema: google_ads; Owner: -
--

CREATE TABLE google_ads."CAMPAIGN_PERFORMANCE_REPORT" (
    __sdc_primary_key text NOT NULL,
    _sdc_batched_at timestamp with time zone,
    _sdc_customer_id text,
    _sdc_extracted_at timestamp with time zone,
    _sdc_received_at timestamp with time zone,
    _sdc_report_datetime timestamp with time zone,
    _sdc_sequence bigint,
    _sdc_table_version bigint,
    "avgCost" bigint,
    "bidStrategyID" bigint,
    "bidStrategyType" text,
    budget bigint,
    "budgetID" bigint,
    campaign text,
    "campaignID" bigint,
    "campaignState" text,
    "campaignTrialType" text,
    "convRate" double precision,
    conversions double precision,
    cost bigint,
    "costConv" bigint,
    currency text,
    day timestamp with time zone,
    impressions bigint,
    "interactionRate" double precision,
    interactions bigint
);


--
-- Name: _sdc_rejected; Type: TABLE; Schema: google_ads; Owner: -
--

CREATE TABLE google_ads._sdc_rejected (
    record text,
    reason text,
    table_name text,
    _sdc_rejected_at timestamp with time zone
);


--
-- Name: ActiveFlashCardChapter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ActiveFlashCardChapter" (
    id bigint NOT NULL,
    "chapterId" integer
);


--
-- Name: ActiveFlashCardChapter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ActiveFlashCardChapter_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ActiveFlashCardChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ActiveFlashCardChapter_id_seq" OWNED BY public."ActiveFlashCardChapter".id;


--
-- Name: Advertisement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Advertisement" (
    id integer NOT NULL,
    "webUrl" character varying(255) NOT NULL,
    "mobileUrl" character varying(255) NOT NULL,
    "startedAt" timestamp with time zone NOT NULL,
    "expiryAt" timestamp with time zone NOT NULL,
    platform public."enum_Advertisement_platform" DEFAULT 'both'::public."enum_Advertisement_platform",
    link character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "backgroundColor" character varying(255),
    context jsonb
);


--
-- Name: Advertisement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Advertisement_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Advertisement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Advertisement_id_seq" OWNED BY public."Advertisement".id;


--
-- Name: Announcement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Announcement" (
    id integer NOT NULL,
    title character varying(255),
    content text,
    "userId" integer,
    "courseId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Announcement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Announcement_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Announcement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Announcement_id_seq" OWNED BY public."Announcement".id;


--
-- Name: Answer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Answer" (
    id integer NOT NULL,
    "userAnswer" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "questionId" integer NOT NULL,
    "userId" integer NOT NULL,
    "testAttemptId" integer,
    "durationInSec" integer,
    "incorrectAnswerReason" character varying(255),
    "incorrectAnswerOther" text
);


--
-- Name: Answer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Answer_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Answer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Answer_id_seq" OWNED BY public."Answer".id;


--
-- Name: AppVersion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AppVersion" (
    id integer NOT NULL,
    name character varying(255),
    version character varying(255),
    description text,
    "forceUpdate" boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: AppVersion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."AppVersion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: AppVersion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."AppVersion_id_seq" OWNED BY public."AppVersion".id;


--
-- Name: BiologyChapterNCERTSeq; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BiologyChapterNCERTSeq" (
    "chapterId" integer NOT NULL,
    "seqId" integer NOT NULL,
    class integer NOT NULL
);


--
-- Name: Question; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question" (
    id integer NOT NULL,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean DEFAULT false NOT NULL,
    type public."enum_Question_type" DEFAULT 'MCQ-SO'::public."enum_Question_type" NOT NULL,
    "paidAccess" boolean DEFAULT false,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean DEFAULT false,
    "sequenceId" integer DEFAULT 0,
    "proofRead" boolean DEFAULT false,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer DEFAULT 0 NOT NULL,
    ncert boolean
)
WITH (autovacuum_enabled='true', autovacuum_vacuum_scale_factor='0.01', autovacuum_analyze_scale_factor='0.005');


--
-- Name: QuestionDetail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionDetail" (
    id integer NOT NULL,
    year integer,
    exam character varying(255),
    "examName" text,
    "questionId" integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: BoardExamQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."BoardExamQuestion" AS
 SELECT "Question".id,
    "Question".deleted
   FROM public."Question"
  WHERE (EXISTS ( SELECT 1
           FROM public."QuestionDetail"
          WHERE (("Question".id = "QuestionDetail"."questionId") AND (("QuestionDetail".exam)::text = 'BOARD'::text))));


--
-- Name: BookmarkQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookmarkQuestion" (
    id integer NOT NULL,
    "questionId" integer NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: BookmarkQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookmarkQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookmarkQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookmarkQuestion_id_seq" OWNED BY public."BookmarkQuestion".id;


--
-- Name: ChapterQuestionCopy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestionCopy" (
    id integer NOT NULL,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ChapterQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterQuestion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterQuestion_id_seq" OWNED BY public."ChapterQuestionCopy".id;


--
-- Name: ChapterQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion" (
    id integer DEFAULT nextval('public."ChapterQuestion_id_seq"'::regclass) NOT NULL,
    "chapterId" integer NOT NULL,
    "questionId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: Topic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Topic" (
    id integer NOT NULL,
    name character varying(255),
    image text,
    description text,
    "position" integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "subjectId" integer,
    free boolean DEFAULT false NOT NULL,
    published boolean DEFAULT false NOT NULL,
    "seqId" integer DEFAULT 0 NOT NULL,
    "importUrl" character varying(255),
    "isComingSoon" boolean DEFAULT false,
    "sectionReady" boolean DEFAULT false
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id integer NOT NULL,
    email character varying(255),
    "emailConfirmed" boolean DEFAULT false,
    "hashedPassword" text,
    phone text,
    "phoneConfirmed" boolean DEFAULT false,
    provider text,
    role character varying(20) DEFAULT 'student'::character varying,
    salt character varying(32),
    "resetPasswordToken" text,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "referrerId" integer,
    "fcmToken" character varying(255),
    source text,
    referrer text,
    "isFcmTokenActive" boolean DEFAULT true,
    "blockedUser" boolean DEFAULT false,
    password text
);


--
-- Name: ChapQuesUserAnswer; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."ChapQuesUserAnswer" AS
 SELECT ((("User".id - 1) * ( SELECT count(*) AS count
           FROM public."Topic" "Topic_1")) + "Topic".id) AS id,
    "Topic".id AS "topicId",
    "User".id AS "userId",
    json_object_agg("Question".id, "Answer"."userAnswer") AS "userAnswers"
   FROM public."Topic",
    public."User",
    public."ChapterQuestion",
    public."Question",
    public."Answer"
  WHERE (("Topic".id = "ChapterQuestion"."chapterId") AND ("ChapterQuestion"."questionId" = "Question".id) AND ("Question".id = "Answer"."questionId") AND ("User".id = "Answer"."userId"))
  GROUP BY "Topic".id, "User".id;


--
-- Name: ChapterFlashCard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterFlashCard" (
    id bigint NOT NULL,
    "chapterId" integer NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "flashCardId" integer NOT NULL,
    "seqId" integer
);


--
-- Name: ChapterFlashCard20200609; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterFlashCard20200609" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: ChapterFlashCard20200924; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterFlashCard20200924" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: ChapterFlashCard20210617; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterFlashCard20210617" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: ChapterFlashCardCopy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterFlashCardCopy" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: ChapterFlashCard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterFlashCard_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterFlashCard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterFlashCard_id_seq" OWNED BY public."ChapterFlashCard".id;


--
-- Name: ChapterGlossary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterGlossary" (
    id bigint NOT NULL,
    "chapterId" integer,
    "glossaryId" integer,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    frequency integer
);


--
-- Name: ChapterGlossary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterGlossary_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterGlossary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterGlossary_id_seq" OWNED BY public."ChapterGlossary".id;


--
-- Name: ChapterMindmap; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterMindmap" (
    id integer NOT NULL,
    "chapterId" integer NOT NULL,
    "noteId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ChapterMindmap_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterMindmap_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterMindmap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterMindmap_id_seq" OWNED BY public."ChapterMindmap".id;


--
-- Name: ChapterName; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterName" (
    name text,
    "chapterId" integer,
    "subjectId" integer
);


--
-- Name: ChapterNote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterNote" (
    id integer NOT NULL,
    "chapterId" integer,
    "noteId" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ChapterNote_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterNote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterNote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterNote_id_seq" OWNED BY public."ChapterNote".id;


--
-- Name: ChapterQuestion20200516; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20200516" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20200528; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20200528" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20200929; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20200929" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20201005; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20201005" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20210129; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20210129" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20210215; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20210215" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20210220; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20210220" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20211801; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20211801" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20211801_1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20211801_1" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20211801_2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion20211801_2" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion26052021; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestion26052021" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestionSet; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterQuestionSet" (
    id integer NOT NULL,
    "testId" integer NOT NULL,
    "chapterId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ChapterQuestionSet_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterQuestionSet_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterQuestionSet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterQuestionSet_id_seq" OWNED BY public."ChapterQuestionSet".id;


--
-- Name: ChapterSubTopicWeightage; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."ChapterSubTopicWeightage" AS
SELECT
    NULL::integer AS "subTopicId",
    NULL::character varying(255) AS "subTopicName",
    NULL::integer AS "chapterId",
    NULL::bigint AS "ncertQuestionCount",
    NULL::numeric AS "chapterCount",
    NULL::numeric AS weightage;


--
-- Name: ChapterTask; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterTask" (
    id integer NOT NULL,
    "chapterId" integer,
    "taskId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ChapterTask_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterTask_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterTask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterTask_id_seq" OWNED BY public."ChapterTask".id;


--
-- Name: ChapterTest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterTest" (
    id integer NOT NULL,
    "chapterId" integer NOT NULL,
    "testId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: SubjectChapter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SubjectChapter" (
    id integer NOT NULL,
    "subjectId" integer NOT NULL,
    "chapterId" integer NOT NULL,
    deleted boolean DEFAULT false,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TestQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TestQuestion" (
    id integer NOT NULL,
    "testId" integer NOT NULL,
    "questionId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "seqNum" integer DEFAULT 0 NOT NULL
);


--
-- Name: ChapterTestQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."ChapterTestQuestion" AS
 SELECT "Topic".id AS "chapterId",
    "Question".id AS "questionId"
   FROM (((public."Topic"
     JOIN ( SELECT ct."chapterId",
            ct."testId"
           FROM ( SELECT "ChapterTest"."chapterId",
                    "ChapterTest"."testId",
                    count(*) OVER (PARTITION BY "ChapterTest"."testId") AS "countChapter"
                   FROM public."ChapterTest",
                    public."SubjectChapter"
                  WHERE (("ChapterTest"."chapterId" = "SubjectChapter"."chapterId") AND ("SubjectChapter"."subjectId" = ANY (ARRAY[53, 54, 55, 56])))) ct
          WHERE (ct."countChapter" = 1)) ct1 ON ((ct1."chapterId" = "Topic".id)))
     JOIN public."TestQuestion" ON (("TestQuestion"."testId" = ct1."testId")))
     JOIN public."Question" ON (("Question".id = "TestQuestion"."questionId")));


--
-- Name: ChapterTest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterTest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterTest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterTest_id_seq" OWNED BY public."ChapterTest".id;


--
-- Name: ChapterVideo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterVideo" (
    id integer NOT NULL,
    "chapterId" integer NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ChapterVideo10012021; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterVideo10012021" (
    id integer,
    "chapterId" integer,
    "videoId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterVideo20210704; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChapterVideo20210704" (
    id integer,
    "chapterId" integer,
    "videoId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: Video; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Video" (
    id integer NOT NULL,
    name character varying(255),
    description text,
    url text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "creatorId" integer,
    thumbnail text,
    duration double precision,
    "seqId" integer DEFAULT 0 NOT NULL,
    "youtubeUrl" character varying(255) DEFAULT NULL::character varying,
    language character varying(255),
    url2 text
);


--
-- Name: ChapterVideoStat; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."ChapterVideoStat" AS
 SELECT "ChapterVideoStatDataWithId".id,
    "ChapterVideoStatDataWithId"."chapterId",
    "ChapterVideoStatDataWithId"."videoCount",
    "ChapterVideoStatDataWithId"."totalDuration"
   FROM ( SELECT "ChapterVideoStatData"."chapterId" AS id,
            "ChapterVideoStatData"."chapterId",
            "ChapterVideoStatData"."videoCount",
            "ChapterVideoStatData"."totalDuration"
           FROM ( SELECT "ChapterVideo"."chapterId",
                    count("Video".id) AS "videoCount",
                    sum("Video".duration) AS "totalDuration"
                   FROM public."ChapterVideo",
                    public."Video",
                    public."SubjectChapter"
                  WHERE (("ChapterVideo"."chapterId" = "SubjectChapter"."chapterId") AND ("SubjectChapter"."subjectId" = ANY (ARRAY[53, 54, 55, 56])) AND ("ChapterVideo"."videoId" = "Video".id) AND ((("Video".language)::text = 'hinglish'::text) OR ("SubjectChapter"."chapterId" = ANY (ARRAY[639, 640]))))
                  GROUP BY "ChapterVideo"."chapterId") "ChapterVideoStatData") "ChapterVideoStatDataWithId"
  WITH NO DATA;


--
-- Name: ChapterVideo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChapterVideo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterVideo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChapterVideo_id_seq" OWNED BY public."ChapterVideo".id;


--
-- Name: VideoSentence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VideoSentence" (
    id bigint NOT NULL,
    "videoId" integer,
    "chapterId" integer,
    "sectionId" integer,
    sentence character varying,
    "timestampStart" double precision,
    "timestampEnd" double precision,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    sentence1 text
);


--
-- Name: ChapterWiseQuestionStopWord; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."ChapterWiseQuestionStopWord" AS
 SELECT chapter_wise_data.topic_id AS "topicId",
    public.get_chapter_wise_stopwords_from_question(chapter_wise_data.topic_id) AS "questionStopwords"
   FROM ( SELECT DISTINCT "VideoSentence"."chapterId" AS topic_id
           FROM public."VideoSentence") chapter_wise_data
  WITH NO DATA;


--
-- Name: ChatAnswer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChatAnswer" (
    id integer NOT NULL,
    "userAnswer" integer,
    "questionId" integer NOT NULL,
    "messageId" integer,
    "groupId" integer,
    "userId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ChatAnswer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChatAnswer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChatAnswer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChatAnswer_id_seq" OWNED BY public."ChatAnswer".id;


--
-- Name: Comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Comment" (
    id integer NOT NULL,
    text text,
    "imgUrl" text,
    "ownerType" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "ownerId" integer,
    "userId" integer
);


--
-- Name: Comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Comment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Comment_id_seq" OWNED BY public."Comment".id;


--
-- Name: Constant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Constant" (
    id integer NOT NULL,
    key text NOT NULL,
    value jsonb NOT NULL
);


--
-- Name: CommonLeaderBoard; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."CommonLeaderBoard" AS
 SELECT "CommonLeaderBoardDatarank".id,
    "CommonLeaderBoardDatarank"."userId",
    "CommonLeaderBoardDatarank".score,
    "CommonLeaderBoardDatarank"."correctAnswerCount",
    "CommonLeaderBoardDatarank"."incorrectAnswerCount",
    rank() OVER (ORDER BY "CommonLeaderBoardDatarank".score DESC) AS rank
   FROM ( SELECT "CommonLeaderBoardData"."userId" AS id,
            "CommonLeaderBoardData"."userId",
            (("CommonLeaderBoardData".score * "CommonLeaderBoardData"."correctAnswerCount") / ("CommonLeaderBoardData"."correctAnswerCount" + "CommonLeaderBoardData"."incorrectAnswerCount")) AS score,
            "CommonLeaderBoardData"."correctAnswerCount",
            "CommonLeaderBoardData"."incorrectAnswerCount"
           FROM ( SELECT "User".id AS "userId",
                    count(
                        CASE
                            WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                            ELSE NULL::integer
                        END) AS "correctAnswerCount",
                    count(
                        CASE
                            WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                            ELSE NULL::integer
                        END) AS "incorrectAnswerCount",
                    count(
                        CASE
                            WHEN ("Answer"."createdAt" > (CURRENT_DATE - ((( SELECT ("Constant".value)::text AS value
                               FROM public."Constant"
                              WHERE ("Constant".key = 'LEADERBOARD_CUTOFF_DAYS'::text)) || ' days'::text))::interval)) THEN 1
                            ELSE NULL::integer
                        END) AS "recentAnswerCount",
                    ((count(
                        CASE
                            WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                            ELSE NULL::integer
                        END) * 4) + (count(
                        CASE
                            WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                            ELSE NULL::integer
                        END) * '-1'::integer)) AS score
                   FROM public."Question",
                    public."Answer",
                    public."User"
                  WHERE (("User".id = "Answer"."userId") AND ("Question".id = "Answer"."questionId"))
                  GROUP BY "User".id) "CommonLeaderBoardData"
          WHERE (("CommonLeaderBoardData"."correctAnswerCount" <> 0) AND ("CommonLeaderBoardData"."incorrectAnswerCount" <> 0) AND ("CommonLeaderBoardData"."recentAnswerCount" > 0))) "CommonLeaderBoardDatarank"
  WITH NO DATA;


--
-- Name: ConfigValue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ConfigValue" (
    id integer NOT NULL,
    "accessToken" text,
    "refreshToken" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ConfigValue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ConfigValue_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ConfigValue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ConfigValue_id_seq" OWNED BY public."ConfigValue".id;


--
-- Name: Constant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Constant_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Constant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Constant_id_seq" OWNED BY public."Constant".id;


--
-- Name: CopyAnswer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyAnswer" (
    id integer NOT NULL,
    "userAnswer" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "questionId" integer,
    "userId" integer,
    "testAttemptId" integer,
    "durationInSec" integer
);


--
-- Name: CopyAnswer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CopyAnswer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CopyAnswer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CopyAnswer_id_seq" OWNED BY public."CopyAnswer".id;


--
-- Name: CopyChapterFlashCard20201111; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyChapterFlashCard20201111" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: CopyCourse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyCourse" (
    id integer,
    name character varying(255),
    image text,
    description text,
    package public."enum_Course_package",
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    fee numeric(10,2),
    public boolean,
    "origFee" numeric(10,2),
    discount numeric(10,2),
    "expiryAt" timestamp with time zone,
    type character varying(255),
    "bestSeller" boolean,
    recommended boolean,
    "discountedFee" numeric(10,2),
    "startedAt" timestamp with time zone,
    "courseGroup" text,
    "typeId" integer,
    year integer,
    "hasVideo" boolean,
    "allowCallback" boolean,
    "hasPartTest" boolean,
    "hasNCERT" boolean,
    "hasQuestionBank" boolean,
    "hasDoubt" boolean,
    "hasLeaderBoard" boolean,
    "shortDescription" character varying,
    "seqId" integer,
    "showPayment" boolean,
    "feeDesc" text
);


--
-- Name: CopyCourseTest20200916; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyCourseTest20200916" (
    id integer,
    "courseId" integer,
    "testId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: CopyNote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyNote" (
    id integer,
    name character varying(255),
    content text,
    description text,
    "creatorId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "externalURL" text,
    "epubURL" text,
    "epubContent" text
);


--
-- Name: CopyQuestion01012019; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyQuestion01012019" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "testId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type"
);


--
-- Name: CopyQuestion010120191; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyQuestion010120191" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "testId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type"
);


--
-- Name: CopyQuestion20200504; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyQuestion20200504" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer
);


--
-- Name: CopyQuestion20201231; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyQuestion20201231" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer
);


--
-- Name: CopyQuestion23092020; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyQuestion23092020" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer
);


--
-- Name: CopyQuestion29092018; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyQuestion29092018" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "testId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type"
);


--
-- Name: CopyQuestionTranslation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyQuestionTranslation" (
    id integer,
    "questionId" integer,
    question text,
    explanation text,
    language character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: CopyQuestionTranslation1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyQuestionTranslation1" (
    id integer,
    "questionId" integer,
    question text,
    explanation text,
    language character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: CopySubjectChapter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopySubjectChapter" (
    id integer,
    "subjectId" integer,
    "chapterId" integer,
    deleted boolean,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: CopyTarget20201111; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyTarget20201111" (
    id bigint,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "userId" integer,
    score integer,
    "testId" integer,
    "targetDate" timestamp without time zone,
    status character varying,
    "maxMarks" integer,
    "testType" character varying
);


--
-- Name: CopyTestAttempt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyTestAttempt" (
    id integer NOT NULL,
    "testId" integer,
    "userId" integer,
    "elapsedDurationInSec" integer,
    "currentQuestionOffset" integer,
    completed boolean,
    "userAnswers" json,
    "userQuestionWiseDurationInSec" json,
    result json,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "visitedQuestions" json,
    "markedQuestions" json
);


--
-- Name: CopyTestAttempt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CopyTestAttempt_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CopyTestAttempt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CopyTestAttempt_id_seq" OWNED BY public."CopyTestAttempt".id;


--
-- Name: CopyTopic20200917; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CopyTopic20200917" (
    id integer,
    name character varying(255),
    image text,
    description text,
    "position" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "subjectId" integer,
    free boolean,
    published boolean,
    "seqId" integer,
    "importUrl" character varying(255),
    "isComingSoon" boolean,
    "sectionReady" boolean
);


--
-- Name: VideoQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VideoQuestion" (
    id integer NOT NULL,
    "videoId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "timestamp" integer
);


--
-- Name: CorrectAnswerVideo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."CorrectAnswerVideo" AS
 SELECT row_number() OVER (ORDER BY "Answer".id, "Video".id) AS id,
    "Question".id AS "questionId",
    "Answer"."userId",
    "Video".id AS "videoId",
    "Answer"."testAttemptId",
    "Answer".id AS "answerId"
   FROM (((public."Question"
     JOIN public."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question"."correctOptionIndex" = "Answer"."userAnswer"))))
     JOIN public."VideoQuestion" ON (("VideoQuestion"."questionId" = "Question".id)))
     JOIN public."Video" ON (("Video".id = "VideoQuestion"."videoId")));


--
-- Name: Coupon; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Coupon" (
    id integer,
    code character varying(255),
    description text,
    quantity integer DEFAULT '-1'::integer NOT NULL,
    discount numeric(10,2) DEFAULT 0 NOT NULL,
    "discountType" public."enum_Coupon_discountType" DEFAULT 'absolute'::public."enum_Coupon_discountType"
);


--
-- Name: Course; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Course" (
    id integer NOT NULL,
    name character varying(255),
    image text,
    description text,
    package public."enum_Course_package" DEFAULT 'k12'::public."enum_Course_package",
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fee numeric(10,2) DEFAULT 0 NOT NULL,
    public boolean DEFAULT false NOT NULL,
    "origFee" numeric(10,2),
    discount numeric(10,2),
    "expiryAt" timestamp with time zone,
    type character varying(255),
    "bestSeller" boolean,
    recommended boolean,
    "discountedFee" numeric(10,2),
    "startedAt" timestamp with time zone,
    "courseGroup" text,
    "typeId" integer,
    year integer,
    "hasVideo" boolean DEFAULT true,
    "allowCallback" boolean DEFAULT true,
    "hasPartTest" boolean DEFAULT true,
    "hasNCERT" boolean DEFAULT true,
    "hasQuestionBank" boolean DEFAULT true,
    "hasDoubt" boolean DEFAULT true,
    "hasLeaderBoard" boolean DEFAULT true,
    "shortDescription" character varying,
    "seqId" integer,
    "showPayment" boolean DEFAULT false NOT NULL,
    "feeDesc" text,
    "hideCourseFee" boolean DEFAULT false,
    "feeTitle" text
);


--
-- Name: Subject; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Subject" (
    id integer NOT NULL,
    name character varying(255),
    image text,
    description text,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "courseId" integer
);


--
-- Name: CourseChapter; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."CourseChapter" AS
 SELECT "Subject"."courseId",
    "SubjectChapter"."chapterId",
    "SubjectChapter"."subjectId"
   FROM public."Subject",
    public."SubjectChapter"
  WHERE (("SubjectChapter"."subjectId" = "Subject".id) AND ("SubjectChapter".deleted = false));


--
-- Name: CourseDetail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CourseDetail" (
    id bigint NOT NULL,
    "courseId" integer NOT NULL,
    description character varying,
    "shortDescription" character varying,
    rating double precision,
    "ratingCount" integer,
    enrolled integer,
    language character varying DEFAULT 'hinglish'::character varying,
    "videoUrl" character varying,
    bestseller boolean DEFAULT false,
    curriculum jsonb DEFAULT '{}'::jsonb,
    features jsonb DEFAULT '{}'::jsonb,
    requirements jsonb DEFAULT '{}'::jsonb,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "bannerImage" character varying,
    "showTrial" boolean DEFAULT false,
    live boolean DEFAULT false
);


--
-- Name: CourseDetail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CourseDetail_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseDetail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CourseDetail_id_seq" OWNED BY public."CourseDetail".id;


--
-- Name: CourseInvitation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CourseInvitation" (
    id integer NOT NULL,
    "courseId" integer NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(255),
    "expiryAt" timestamp with time zone NOT NULL,
    role public."enum_CourseInvitation_role" DEFAULT 'courseStudent'::public."enum_CourseInvitation_role" NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "displayName" character varying(100),
    "creatorId" integer,
    "paymentId" integer,
    admin_user_id integer,
    CONSTRAINT expiratcheck CHECK (("expiryAt" <= (CURRENT_TIMESTAMP + '6 years'::interval)))
);


--
-- Name: CourseInvitation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CourseInvitation_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseInvitation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CourseInvitation_id_seq" OWNED BY public."CourseInvitation".id;


--
-- Name: CourseOffer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CourseOffer" (
    id integer NOT NULL,
    title character varying(255),
    description text,
    "courseId" integer NOT NULL,
    fee numeric(10,2) NOT NULL,
    "discountedFee" numeric(10,2),
    email character varying(255),
    phone character varying(255),
    "expiryAt" timestamp with time zone,
    "durationInDays" integer,
    "offerExpiryAt" timestamp with time zone,
    "offerStartedAt" timestamp with time zone,
    admin_user_id integer,
    hidden boolean DEFAULT false NOT NULL,
    "position" integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "actualCourseId" integer,
    accepted boolean DEFAULT false
);


--
-- Name: CourseOffer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CourseOffer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseOffer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CourseOffer_id_seq" OWNED BY public."CourseOffer".id;


--
-- Name: CourseQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."CourseQuestion" AS
 SELECT "Subject"."courseId",
    "Subject".id AS "subjectId",
    "SubjectChapter"."chapterId",
    "ChapterQuestion"."questionId"
   FROM public."Subject",
    public."SubjectChapter",
    public."ChapterQuestion",
    public."Question"
  WHERE (("SubjectChapter"."subjectId" = "Subject".id) AND ("SubjectChapter"."chapterId" = "ChapterQuestion"."chapterId") AND ("ChapterQuestion"."questionId" = "Question".id) AND ("Question".deleted = false) AND ("SubjectChapter".deleted = false));


--
-- Name: CourseTest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CourseTest" (
    id integer NOT NULL,
    "courseId" integer NOT NULL,
    "testId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: CourseTestQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."CourseTestQuestion" AS
 SELECT "CourseTest"."courseId",
    "TestQuestion"."questionId",
    "Question"."topicId" AS "chapterId",
    "Question"."subjectId",
    "CourseTest"."testId"
   FROM public."CourseTest",
    public."TestQuestion",
    public."Question"
  WHERE (("CourseTest"."testId" = "TestQuestion"."testId") AND ("TestQuestion"."questionId" = "Question".id) AND ("Question".deleted = false));


--
-- Name: CourseTest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CourseTest_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseTest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CourseTest_id_seq" OWNED BY public."CourseTest".id;


--
-- Name: CourseTestimonial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CourseTestimonial" (
    id integer NOT NULL,
    "courseId" integer NOT NULL,
    content text NOT NULL,
    author character varying(255) NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: CourseTestimonial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CourseTestimonial_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseTestimonial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CourseTestimonial_id_seq" OWNED BY public."CourseTestimonial".id;


--
-- Name: CourseVideo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."CourseVideo" AS
 SELECT "Subject"."courseId",
    "Subject".id AS "subjectId",
    "SubjectChapter"."chapterId",
    "ChapterVideo"."videoId"
   FROM public."Subject",
    public."SubjectChapter",
    public."ChapterVideo",
    public."Video"
  WHERE (("SubjectChapter"."subjectId" = "Subject".id) AND ("SubjectChapter"."chapterId" = "ChapterVideo"."chapterId") AND ("ChapterVideo"."videoId" = "Video".id) AND ("SubjectChapter".deleted = false));


--
-- Name: Course_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Course_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Course_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Course_id_seq" OWNED BY public."Course".id;


--
-- Name: CustomerIssue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomerIssue" (
    id integer NOT NULL,
    description text NOT NULL,
    "typeId" integer NOT NULL,
    "questionId" integer,
    "videoId" integer,
    "noteId" integer,
    "topicId" integer,
    deleted boolean DEFAULT false,
    resolved boolean DEFAULT false,
    "userId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "testId" integer,
    "flashCardId" integer,
    "adminUserId" integer
);


--
-- Name: CustomerIssue20201120; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomerIssue20201120" (
    id integer,
    description text,
    "typeId" integer,
    "questionId" integer,
    "videoId" integer,
    "noteId" integer,
    "topicId" integer,
    deleted boolean,
    resolved boolean,
    "userId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "testId" integer,
    "flashCardId" integer
);


--
-- Name: CustomerIssueType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomerIssueType" (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    "displayName" character varying(255) NOT NULL,
    description text NOT NULL,
    "focusArea" character varying(255) NOT NULL,
    deleted boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: CustomerIssueType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CustomerIssueType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CustomerIssueType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CustomerIssueType_id_seq" OWNED BY public."CustomerIssueType".id;


--
-- Name: CustomerIssue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CustomerIssue_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CustomerIssue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CustomerIssue_id_seq" OWNED BY public."CustomerIssue".id;


--
-- Name: CustomerSupport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomerSupport" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    content character varying(255),
    phone character varying(255),
    "issueType" character varying(255),
    deleted boolean DEFAULT false,
    resolved boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    email character varying,
    "userData" character varying,
    "adminUserId" integer
);


--
-- Name: CustomerSupport_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CustomerSupport_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CustomerSupport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CustomerSupport_id_seq" OWNED BY public."CustomerSupport".id;


--
-- Name: DailyUserEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DailyUserEvent" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "eventDate" date NOT NULL,
    event character varying(25) NOT NULL,
    "eventCount" integer NOT NULL,
    "courseId" integer
);


--
-- Name: DailyUserEvent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DailyUserEvent_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DailyUserEvent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DailyUserEvent_id_seq" OWNED BY public."DailyUserEvent".id;


--
-- Name: Delivery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Delivery" (
    id integer NOT NULL,
    "deliveryType" character varying(255),
    course character varying(255),
    "courseValidity" timestamp with time zone,
    amount integer,
    source character varying(255),
    "purchasedAt" timestamp with time zone,
    name character varying(255),
    mobile character varying(255),
    address text,
    "counselorName" character varying(255),
    "trackingNumber" character varying(255),
    usb character varying(255),
    dongle character varying(255),
    delivered boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "purchasedAtText" character varying(255),
    "installmentAmount" character varying(255),
    packed boolean,
    description text,
    email character varying(255),
    "courierSource" character varying(255),
    "dueDate" timestamp with time zone,
    "dueAmount" integer,
    status character varying(255)
);


--
-- Name: Delivery_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Delivery_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Delivery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Delivery_id_seq" OWNED BY public."Delivery".id;


--
-- Name: Doubt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Doubt" (
    id integer NOT NULL,
    content text,
    "imgUrl" text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "topicId" integer,
    "userId" integer,
    deleted boolean DEFAULT false NOT NULL,
    "tagType" character varying(255),
    "questionId" integer,
    "noteId" integer,
    "videoId" integer,
    "testId" integer,
    "teacherReply" text,
    "doubtType" public."enum_Doubt_doubtType",
    "goodFlag" boolean DEFAULT false,
    "audioLink" character varying,
    "voteCount" integer DEFAULT 0,
    "doubtSolved" boolean DEFAULT false
);


--
-- Name: DoubtAnswer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DoubtAnswer" (
    id integer NOT NULL,
    content text,
    "imgUrl" text,
    accepted boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "doubtId" integer,
    "userId" integer,
    deleted boolean DEFAULT false
);


--
-- Name: DoubtAnswer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DoubtAnswer_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DoubtAnswer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DoubtAnswer_id_seq" OWNED BY public."DoubtAnswer".id;


--
-- Name: Doubt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Doubt_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Doubt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Doubt_id_seq" OWNED BY public."Doubt".id;


--
-- Name: DuplicateChapter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DuplicateChapter" (
    id integer NOT NULL,
    "origId" integer NOT NULL,
    "dupId" integer NOT NULL
);


--
-- Name: DuplicateChapter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DuplicateChapter_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DuplicateChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DuplicateChapter_id_seq" OWNED BY public."DuplicateChapter".id;


--
-- Name: DuplicatePost; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DuplicatePost" (
    id integer NOT NULL,
    "postId" integer NOT NULL,
    content text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: DuplicatePost_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DuplicatePost_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DuplicatePost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DuplicatePost_id_seq" OWNED BY public."DuplicatePost".id;


--
-- Name: DuplicateQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DuplicateQuestion" (
    id integer NOT NULL,
    "questionId1" integer NOT NULL,
    "questionId2" integer NOT NULL,
    similarity numeric(5,4),
    CONSTRAINT "DuplicateQuestion_questionId1_less_than_questionId2" CHECK (("questionId1" < "questionId2"))
);


--
-- Name: DuplicateQuestion20200710; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DuplicateQuestion20200710" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer
);


--
-- Name: DuplicateQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DuplicateQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DuplicateQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DuplicateQuestion_id_seq" OWNED BY public."DuplicateQuestion".id;


--
-- Name: ExamQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."ExamQuestion" AS
 SELECT "Question".id,
    "Question".deleted
   FROM public."Question"
  WHERE (EXISTS ( SELECT 1
           FROM public."QuestionDetail"
          WHERE (("Question".id = "QuestionDetail"."questionId") AND ((("QuestionDetail".exam)::text <> 'BOARD'::text) OR ("QuestionDetail".exam IS NULL)))));


--
-- Name: FcmToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FcmToken" (
    id integer NOT NULL,
    "fcmToken" character varying(255) NOT NULL,
    "deviceId" character varying(255),
    "androidDetails" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "userId" integer,
    platform character varying(255),
    "deviceAdsId" character varying(255) DEFAULT NULL::character varying
);


--
-- Name: FcmToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."FcmToken_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: FcmToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."FcmToken_id_seq" OWNED BY public."FcmToken".id;


--
-- Name: FestivalDiscount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FestivalDiscount" (
    id integer NOT NULL,
    title character varying(255),
    description text,
    flag boolean DEFAULT true NOT NULL,
    "startDate" timestamp with time zone NOT NULL,
    "endDate" timestamp with time zone NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: FestivalDiscount_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."FestivalDiscount_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: FestivalDiscount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."FestivalDiscount_id_seq" OWNED BY public."FestivalDiscount".id;


--
-- Name: FlashCard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FlashCard" (
    id bigint NOT NULL,
    content character varying,
    title character varying,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- Name: FlashCard20200609; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FlashCard20200609" (
    id bigint,
    content character varying,
    title character varying,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);


--
-- Name: FlashCard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."FlashCard_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: FlashCard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."FlashCard_id_seq" OWNED BY public."FlashCard".id;


--
-- Name: Glossary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Glossary" (
    id bigint NOT NULL,
    word character varying,
    translation character varying,
    language character varying,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- Name: Glossary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Glossary_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Glossary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Glossary_id_seq" OWNED BY public."Glossary".id;


--
-- Name: Group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Group" (
    id integer NOT NULL,
    title character varying(255),
    description character varying(255),
    "startedAt" timestamp with time zone NOT NULL,
    "expiryAt" timestamp with time zone NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "liveSessionUrl" character varying(255)
);


--
-- Name: Group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Group_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Group_id_seq" OWNED BY public."Group".id;


--
-- Name: HindiDuplicateChapter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HindiDuplicateChapter" (
    id integer,
    "origId" integer,
    "dupId" integer
);


--
-- Name: IncorrectAnswerVideo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."IncorrectAnswerVideo" AS
 SELECT row_number() OVER (ORDER BY "Answer".id, "Video".id) AS id,
    "Answer"."testAttemptId",
    "Question".id AS "questionId",
    "Answer"."userId",
    "Video".id AS "videoId",
    "Answer".id AS "answerId"
   FROM (((public."Question"
     JOIN public."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question"."correctOptionIndex" <> "Answer"."userAnswer"))))
     JOIN public."VideoQuestion" ON (("VideoQuestion"."questionId" = "Question".id)))
     JOIN public."Video" ON (("Video".id = "VideoQuestion"."videoId")));


--
-- Name: Installment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Installment" (
    id integer NOT NULL,
    "paymentId" integer NOT NULL,
    "secondInstallmentDate" timestamp with time zone,
    "secondInstallmentAmount" integer,
    "finalInstallmentDate" timestamp with time zone,
    "finalInstallmentAmount" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Installment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Installment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Installment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Installment_id_seq" OWNED BY public."Installment".id;


--
-- Name: MasterClassFreeUser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MasterClassFreeUser" (
    "userId" integer,
    total_count bigint
);


--
-- Name: Message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Message" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "groupId" integer NOT NULL,
    content character varying(255),
    type public."enum_Message_type" DEFAULT 'normal'::public."enum_Message_type",
    deleted boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "questionId" integer
);


--
-- Name: Message_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Message_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Message_id_seq" OWNED BY public."Message".id;


--
-- Name: Motivation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Motivation" (
    id integer NOT NULL,
    message text NOT NULL,
    author character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Motivation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Motivation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Motivation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Motivation_id_seq" OWNED BY public."Motivation".id;


--
-- Name: NCERTQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NCERTQuestion" (
    id integer NOT NULL,
    "questionId" integer
);


--
-- Name: NCERTQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NCERTQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NCERTQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NCERTQuestion_id_seq" OWNED BY public."NCERTQuestion".id;


--
-- Name: NEETExamResult; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NEETExamResult" (
    id integer NOT NULL,
    name character varying(255),
    dob date,
    nationality character varying(100),
    score integer,
    rank integer,
    state character varying(50),
    year integer,
    "stateRank" integer,
    category character varying(20)
);


--
-- Name: NEETExamResult_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NEETExamResult_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NEETExamResult_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NEETExamResult_id_seq" OWNED BY public."NEETExamResult".id;


--
-- Name: NcertChapterQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NcertChapterQuestion" (
    id integer NOT NULL,
    "chapterId" integer NOT NULL,
    "questionId" integer NOT NULL,
    "questionTitle" character varying(255),
    "ncertQuestionType" public."enum_Ncert_question_type" DEFAULT 'Exercises'::public."enum_Ncert_question_type" NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: NcertChapterQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NcertChapterQuestion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NcertChapterQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NcertChapterQuestion_id_seq" OWNED BY public."NcertChapterQuestion".id;


--
-- Name: NcertSentence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NcertSentence" (
    id bigint NOT NULL,
    "noteId" integer,
    "chapterId" integer,
    "sectionId" integer,
    sentence character varying,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "sentenceHtml" text
);


--
-- Name: Note; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Note" (
    id integer NOT NULL,
    name character varying(255),
    content text,
    description text,
    "creatorId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "externalURL" text,
    "epubURL" text,
    "epubContent" text,
    lock_version integer DEFAULT 0 NOT NULL
);


--
-- Name: NcertSentenceDetail; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."NcertSentenceDetail" AS
 SELECT "NcertSentence".id,
    "NcertSentence".id AS "ncertSentenceId",
    "NcertSentence".sentence,
    lead("NcertSentence".sentence, 1) OVER (PARTITION BY "NcertSentence"."noteId" ORDER BY "NcertSentence".id) AS "nextSentence",
    lag("NcertSentence".sentence, 1) OVER (PARTITION BY "NcertSentence"."noteId" ORDER BY "NcertSentence".id) AS "prevSentence",
    "Note".name AS "noteName"
   FROM public."NcertSentence",
    public."Note"
  WHERE ("NcertSentence"."noteId" = "Note".id);


--
-- Name: NcertSentence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NcertSentence_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NcertSentence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NcertSentence_id_seq" OWNED BY public."NcertSentence".id;


--
-- Name: NewUserVideoStat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NewUserVideoStat" (
    id integer,
    "userId" integer,
    "videoId" integer,
    "lastPosition" double precision,
    completed boolean,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: NksAppVersion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NksAppVersion" (
    id integer NOT NULL,
    name character varying(255),
    version character varying(255),
    description text,
    "forceUpdate" boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: NksAppVersion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NksAppVersion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NksAppVersion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NksAppVersion_id_seq" OWNED BY public."NksAppVersion".id;


--
-- Name: NotDuplicateQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NotDuplicateQuestion" (
    "questionId1" integer NOT NULL,
    "questionId2" integer NOT NULL,
    id integer NOT NULL,
    CONSTRAINT "NotDuplicateQuestion_questionId1_less_than_questionId2" CHECK (("questionId1" < "questionId2"))
);


--
-- Name: NotDuplicateQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NotDuplicateQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NotDuplicateQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NotDuplicateQuestion_id_seq" OWNED BY public."NotDuplicateQuestion".id;


--
-- Name: Note03112020; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Note03112020" (
    id integer,
    name character varying(255),
    content text,
    description text,
    "creatorId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "externalURL" text,
    "epubURL" text,
    "epubContent" text,
    lock_version integer
);


--
-- Name: Note20201026; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Note20201026" (
    id integer,
    name character varying(255),
    content text,
    description text,
    "creatorId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "externalURL" text,
    "epubURL" text,
    "epubContent" text,
    lock_version integer
);


--
-- Name: Note20210410; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Note20210410" (
    id integer,
    name character varying(255),
    content text,
    description text,
    "creatorId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "externalURL" text,
    "epubURL" text,
    "epubContent" text,
    lock_version integer
);


--
-- Name: Note_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Note_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Note_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Note_id_seq" OWNED BY public."Note".id;


--
-- Name: Notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Notification" (
    id integer NOT NULL,
    "userId" integer,
    "contextId" integer,
    "contextType" character varying(255),
    title text,
    body text,
    "actionUrl" text,
    "senderName" character varying(255),
    "senderEmail" character varying(255),
    "scheduledAt" timestamp with time zone,
    "sendEmail" boolean,
    "sendAppNotification" boolean,
    "sendWebNotification" boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "imgUrl" text
);


--
-- Name: Notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Notification_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Notification_id_seq" OWNED BY public."Notification".id;


--
-- Name: OldCourseTest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OldCourseTest" (
    id integer NOT NULL,
    "courseId" integer,
    "testId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: OldCourseTest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OldCourseTest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: OldCourseTest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."OldCourseTest_id_seq" OWNED BY public."OldCourseTest".id;


--
-- Name: Payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Payment" (
    id integer NOT NULL,
    request json,
    response json,
    status public."enum_Payment_status" DEFAULT 'created'::public."enum_Payment_status",
    "paymentForId" integer,
    "paymentForType" character varying(255),
    "purchasedItemId" integer,
    "purchasedItemType" character varying(255),
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" integer,
    amount numeric(10,2) NOT NULL,
    "userName" character varying(255),
    "userEmail" character varying(255),
    "userPhone" character varying(255),
    "paymentMode" character varying(255) DEFAULT 'paytm'::character varying,
    "paymentDesc" text,
    "courseExpiryAt" timestamp with time zone,
    verified boolean DEFAULT false,
    "saleType" character varying(255),
    "userState" character varying(255),
    "userCity" character varying(255),
    "salesPerson" character varying(255),
    revenue integer,
    "paytmCut" integer,
    "gstCut" integer,
    "pendriveCut" integer,
    "netRevenue" integer,
    "courseOfferId" integer
);


--
-- Name: PaymentConversion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PaymentConversion" (
    id bigint NOT NULL,
    utm_campaign character varying,
    utm_source character varying,
    utm_medium character varying,
    campaignid character varying,
    adgroupid character varying,
    keyword character varying,
    matchtype character varying,
    creative character varying,
    placement character varying,
    target character varying,
    gclid character varying,
    "paymentId" integer NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- Name: PaymentConversion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."PaymentConversion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PaymentConversion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."PaymentConversion_id_seq" OWNED BY public."PaymentConversion".id;


--
-- Name: PaymentCourseInvitation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PaymentCourseInvitation" (
    id integer NOT NULL,
    "paymentId" integer NOT NULL,
    "courseInvitationId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: PaymentCourseInvitation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."PaymentCourseInvitation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PaymentCourseInvitation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."PaymentCourseInvitation_id_seq" OWNED BY public."PaymentCourseInvitation".id;


--
-- Name: Payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Payment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Payment_id_seq" OWNED BY public."Payment".id;


--
-- Name: Post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Post" (
    id integer NOT NULL,
    url text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    section_1 text,
    section_2 text,
    section_3 text,
    section_4 text,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "highIntent" boolean DEFAULT false
);


--
-- Name: Post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Post_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Post_id_seq" OWNED BY public."Post".id;


--
-- Name: Question20200516; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question20200516" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer
);


--
-- Name: Question20201305; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question20201305" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer
);


--
-- Name: Question20203011; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question20203011" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer
);


--
-- Name: Question20210211; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question20210211" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer,
    ncert boolean
);


--
-- Name: Question20210514; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question20210514" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer,
    ncert boolean
);


--
-- Name: Question20210607; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question20210607" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer,
    ncert boolean
);


--
-- Name: Question20210811; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Question20210811" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer,
    ncert boolean
);


--
-- Name: QuestionCopy; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."QuestionCopy" AS
 SELECT "CopyQuestion29092018".id,
    "CopyQuestion29092018".question,
    "CopyQuestion29092018".options,
    "CopyQuestion29092018"."correctOptionIndex",
    "CopyQuestion29092018".explanation,
    "CopyQuestion29092018"."createdAt",
    "CopyQuestion29092018"."updatedAt",
    "CopyQuestion29092018"."creatorId",
    "CopyQuestion29092018"."testId",
    "CopyQuestion29092018"."canvasQuestionId",
    "CopyQuestion29092018"."canvasQuizId",
    "CopyQuestion29092018".deleted,
    "CopyQuestion29092018".type
   FROM public."CopyQuestion29092018";


--
-- Name: QuestionCourse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionCourse" (
    "questionId" integer NOT NULL,
    "courseId" integer NOT NULL
);


--
-- Name: QuestionDetail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuestionDetail_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionDetail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuestionDetail_id_seq" OWNED BY public."QuestionDetail".id;


--
-- Name: QuestionExplanation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionExplanation" (
    id integer NOT NULL,
    "questionId" integer,
    explanation text,
    language character varying(255),
    "courseId" integer,
    deleted boolean,
    "position" integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: QuestionExplanation20200516; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionExplanation20200516" (
    id integer,
    "questionId" integer,
    explanation text,
    language character varying(255),
    "courseId" integer,
    deleted boolean,
    "position" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: QuestionExplanation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuestionExplanation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionExplanation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuestionExplanation_id_seq" OWNED BY public."QuestionExplanation".id;


--
-- Name: QuestionHint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionHint" (
    id integer NOT NULL,
    "questionId" integer,
    hint text,
    language character varying(255),
    "courseId" integer DEFAULT 8,
    deleted boolean,
    "position" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "videoLinkId" integer
);


--
-- Name: QuestionHint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuestionHint_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionHint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuestionHint_id_seq" OWNED BY public."QuestionHint".id;


--
-- Name: QuestionNcertSentence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionNcertSentence" (
    id integer NOT NULL,
    "questionId" integer NOT NULL,
    "ncertSentenceId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comment character varying
);


--
-- Name: QuestionNcertSentence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuestionNcertSentence_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionNcertSentence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuestionNcertSentence_id_seq" OWNED BY public."QuestionNcertSentence".id;


--
-- Name: QuestionSubTopic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionSubTopic" (
    id integer NOT NULL,
    "questionId" integer NOT NULL,
    "subTopicId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: QuestionSubTopic_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuestionSubTopic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionSubTopic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuestionSubTopic_id_seq" OWNED BY public."QuestionSubTopic".id;


--
-- Name: QuestionTranslation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionTranslation" (
    id integer NOT NULL,
    "questionId" integer NOT NULL,
    question text,
    explanation text,
    language character varying(255) NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reviewed boolean DEFAULT false,
    completed boolean DEFAULT false,
    "newQuestionId" integer
);


--
-- Name: QuestionTranslation20201119; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionTranslation20201119" (
    id integer,
    "questionId" integer,
    question text,
    explanation text,
    language character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    reviewed boolean,
    completed boolean
);


--
-- Name: QuestionTranslation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuestionTranslation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionTranslation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuestionTranslation_id_seq" OWNED BY public."QuestionTranslation".id;


--
-- Name: QuestionVideoSentence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionVideoSentence" (
    id bigint NOT NULL,
    "questionId" integer,
    "videoSentenceId" integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    comment character varying
);


--
-- Name: QuestionVideoSentence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuestionVideoSentence_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionVideoSentence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuestionVideoSentence_id_seq" OWNED BY public."QuestionVideoSentence".id;


--
-- Name: QuestionVimeo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuestionVimeo" (
    id integer NOT NULL,
    "questionId" integer,
    "youtubIframe" text NOT NULL,
    "vimeoIframe" text NOT NULL
);


--
-- Name: QuestionVimeo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuestionVimeo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionVimeo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuestionVimeo_id_seq" OWNED BY public."QuestionVimeo".id;


--
-- Name: Question_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Question_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Question_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Question_id_seq" OWNED BY public."Question".id;


--
-- Name: QuetionMasterClassYoutubeVideo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuetionMasterClassYoutubeVideo" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer,
    ncert boolean
);


--
-- Name: QuetionMasterClassYoutubeVideo1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuetionMasterClassYoutubeVideo1" (
    id integer,
    question text,
    options json,
    "correctOptionIndex" integer,
    explanation text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    "canvasQuestionId" integer,
    "canvasQuizId" integer,
    deleted boolean,
    type public."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level public."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer,
    ncert boolean
);


--
-- Name: Quiz; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Quiz" (
    id integer NOT NULL,
    name character varying(255),
    description text,
    "timeRequiredInSeconds" integer,
    "creatorId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Quiz_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Quiz_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Quiz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Quiz_id_seq" OWNED BY public."Quiz".id;


--
-- Name: RemovedSyllabusSubTopic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RemovedSyllabusSubTopic" (
    id integer NOT NULL,
    "chapterId" integer NOT NULL,
    "subTopicId" integer NOT NULL,
    year integer NOT NULL
);


--
-- Name: RemovedSyllabusSubTopic_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."RemovedSyllabusSubTopic_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: RemovedSyllabusSubTopic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."RemovedSyllabusSubTopic_id_seq" OWNED BY public."RemovedSyllabusSubTopic".id;


--
-- Name: ReplaceDuplicateQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."ReplaceDuplicateQuestion" AS
 SELECT min("DuplicateQuestion"."questionId1") AS "keepQuestionId",
    "DuplicateQuestion"."questionId2" AS "removeQuestionId"
   FROM public."DuplicateQuestion"
  GROUP BY "DuplicateQuestion"."questionId2";


--
-- Name: SEOData; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SEOData" (
    id integer NOT NULL,
    "ownerId" integer,
    "ownerType" character varying(255),
    title text,
    description text,
    keywords text,
    paragraph text,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "ogImage" character varying(255)
);


--
-- Name: SEOData_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SEOData_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SEOData_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SEOData_id_seq" OWNED BY public."SEOData".id;


--
-- Name: Schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Schedule" (
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    name text,
    description text,
    "isActive" boolean
);


--
-- Name: ScheduleItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScheduleItem" (
    id integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text,
    description text,
    "scheduleId" integer NOT NULL,
    "topicId" integer,
    hours integer,
    link text,
    "scheduledAt" timestamp with time zone
);


--
-- Name: ScheduleItemAsset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScheduleItemAsset" (
    id bigint NOT NULL,
    "ScheduleItem_id" bigint,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "assetLink" text,
    "assetName" character varying
);


--
-- Name: ScheduleItemAssetBak; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScheduleItemAssetBak" (
    id bigint,
    "ScheduleItem_id" bigint,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "assetLink" text,
    "assetName" character varying
);


--
-- Name: ScheduleItemAsset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ScheduleItemAsset_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ScheduleItemAsset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ScheduleItemAsset_id_seq" OWNED BY public."ScheduleItemAsset".id;


--
-- Name: ScheduleItemBak; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScheduleItemBak" (
    id integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    description text,
    "scheduleId" integer,
    "topicId" integer,
    hours integer,
    link text,
    "scheduledAt" timestamp with time zone
);


--
-- Name: ScheduleItemUser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScheduleItemUser" (
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "scheduleItemId" integer NOT NULL,
    "userId" integer NOT NULL,
    completed boolean
);


--
-- Name: ScheduleItemUser_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ScheduleItemUser_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ScheduleItemUser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ScheduleItemUser_id_seq" OWNED BY public."ScheduleItemUser".id;


--
-- Name: ScheduleItem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ScheduleItem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ScheduleItem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ScheduleItem_id_seq" OWNED BY public."ScheduleItem".id;


--
-- Name: Schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Schedule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Schedule_id_seq" OWNED BY public."Schedule".id;


--
-- Name: ScheduledTask; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScheduledTask" (
    id integer NOT NULL,
    "parentId" integer,
    "courseId" integer,
    title text,
    link text,
    "desc" text,
    duration numeric(5,2),
    year integer,
    "scheduledAt" timestamp with time zone,
    "expiredAt" timestamp with time zone,
    "taskId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ScheduledTask_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ScheduledTask_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ScheduledTask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ScheduledTask_id_seq" OWNED BY public."ScheduledTask".id;


--
-- Name: Section; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Section" (
    id bigint NOT NULL,
    name character varying NOT NULL,
    "chapterId" integer NOT NULL,
    "position" integer DEFAULT 0,
    "ncertName" character varying,
    "ncertURL" character varying,
    "ncertSectionLink" character varying,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: SectionContent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SectionContent" (
    id bigint NOT NULL,
    title character varying,
    "contentId" integer NOT NULL,
    "contentType" character varying NOT NULL,
    "position" integer DEFAULT 0,
    "sectionId" integer NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: SectionContent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SectionContent_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SectionContent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SectionContent_id_seq" OWNED BY public."SectionContent".id;


--
-- Name: Section_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Section_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Section_id_seq" OWNED BY public."Section".id;


--
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


--
-- Name: SimilarChapterQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."SimilarChapterQuestion" AS
 SELECT q1.id AS "questionId1",
    q2.id AS "questionId2",
    q1."topicId" AS "chapterId"
   FROM public."Question" q1,
    public."Question" q2
  WHERE ((q1.id < q2.id) AND (q1."topicId" = q2."topicId") AND (public.similarity(q1.question, q2.question) > (0.8)::double precision) AND (q1.type = q2.type) AND (q1.type = 'MCQ-SO'::public."enum_Question_type"));


--
-- Name: StudentNote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."StudentNote" (
    id bigint NOT NULL,
    "userId" integer NOT NULL,
    "questionId" integer,
    "flashcardId" integer,
    note character varying,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "chapterId" integer,
    url character varying,
    "noteId" integer,
    details jsonb,
    "noteRange" int4range,
    "videoId" integer,
    "studentAttachImgUri" text
);


--
-- Name: StudentNote_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."StudentNote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: StudentNote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."StudentNote_id_seq" OWNED BY public."StudentNote".id;


--
-- Name: StudentOnboardingEvents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."StudentOnboardingEvents" (
    id bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "userId" integer,
    description character varying
);


--
-- Name: StudentOnboardingEvents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."StudentOnboardingEvents_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: StudentOnboardingEvents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."StudentOnboardingEvents_id_seq" OWNED BY public."StudentOnboardingEvents".id;


--
-- Name: SubTopic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SubTopic" (
    id integer NOT NULL,
    "topicId" integer,
    name character varying(255),
    deleted boolean DEFAULT false,
    "position" integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "videoOnly" boolean DEFAULT false
);


--
-- Name: SubTopic_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SubTopic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SubTopic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SubTopic_id_seq" OWNED BY public."SubTopic".id;


--
-- Name: SubjectChapter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SubjectChapter_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SubjectChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SubjectChapter_id_seq" OWNED BY public."SubjectChapter".id;


--
-- Name: TopicQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."TopicQuestion" AS
 SELECT "Question".id,
    "ChapterQuestion"."chapterId" AS "topicId"
   FROM public."Question",
    public."ChapterQuestion"
  WHERE (("Question".deleted = false) AND ("Question".id = "ChapterQuestion"."questionId"));


--
-- Name: SubjectLeaderBoard; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."SubjectLeaderBoard" AS
 SELECT "SubjectLeaderboardTableData".id,
    "SubjectLeaderboardTableData".rank,
    "SubjectLeaderboardTableData"."userId",
    "SubjectLeaderboardTableData"."subjectId",
    "SubjectLeaderboardTableData".score,
    "SubjectLeaderboardTableData"."correctAnswerCount",
    "SubjectLeaderboardTableData"."incorrectAnswerCount"
   FROM ( SELECT row_number() OVER () AS id,
            row_number() OVER (PARTITION BY "SubjectLeaderboardTable"."subjectId" ORDER BY "SubjectLeaderboardTable".score DESC) AS rank,
            "SubjectLeaderboardTable"."userId",
            "SubjectLeaderboardTable"."subjectId",
            "SubjectLeaderboardTable".score,
            "SubjectLeaderboardTable"."correctAnswerCount",
            "SubjectLeaderboardTable"."incorrectAnswerCount"
           FROM ( SELECT subjectleaderboarddata."userId",
                    subjectleaderboarddata."subjectId",
                    ((subjectleaderboarddata.score * subjectleaderboarddata."correctAnswerCount") / (subjectleaderboarddata."correctAnswerCount" + subjectleaderboarddata."incorrectAnswerCount")) AS score,
                    subjectleaderboarddata."correctAnswerCount",
                    subjectleaderboarddata."incorrectAnswerCount"
                   FROM ( SELECT "User".id AS "userId",
                            count(
                                CASE
                                    WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                                    ELSE NULL::integer
                                END) AS "correctAnswerCount",
                            count(
                                CASE
                                    WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                                    ELSE NULL::integer
                                END) AS "incorrectAnswerCount",
                            ((count(
                                CASE
                                    WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                                    ELSE NULL::integer
                                END) * 4) + (count(
                                CASE
                                    WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                                    ELSE NULL::integer
                                END) * '-1'::integer)) AS score,
                            "Subject".id AS "subjectId"
                           FROM public."Question",
                            public."TopicQuestion",
                            public."Topic",
                            public."Subject",
                            public."Answer",
                            public."User"
                          WHERE (("User".id = "Answer"."userId") AND ("Question".id = "Answer"."questionId") AND ("TopicQuestion".id = "Answer"."questionId") AND ("Question".deleted = false) AND ("TopicQuestion"."topicId" = "Topic".id) AND ("Topic"."subjectId" = "Subject".id) AND ("Subject"."courseId" = 8))
                          GROUP BY "Subject".id, "User".id) subjectleaderboarddata
                  WHERE (subjectleaderboarddata."correctAnswerCount" <> 0)) "SubjectLeaderboardTable") "SubjectLeaderboardTableData"
  WITH NO DATA;


--
-- Name: Subject_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Subject_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Subject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Subject_id_seq" OWNED BY public."Subject".id;


--
-- Name: Target; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Target" (
    id bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "userId" integer NOT NULL,
    score integer NOT NULL,
    "testId" integer,
    "targetDate" timestamp without time zone,
    status character varying DEFAULT 'active'::character varying,
    "maxMarks" integer DEFAULT 720,
    "testType" character varying
);


--
-- Name: TargetChapter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TargetChapter" (
    id bigint NOT NULL,
    "chapterId" integer NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "targetId" integer NOT NULL,
    hours integer NOT NULL,
    revision boolean DEFAULT false
);


--
-- Name: TargetChapter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TargetChapter_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TargetChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TargetChapter_id_seq" OWNED BY public."TargetChapter".id;


--
-- Name: Target_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Target_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Target_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Target_id_seq" OWNED BY public."Target".id;


--
-- Name: Task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Task" (
    id integer NOT NULL,
    "parentId" integer,
    "courseId" integer,
    "seqId" integer,
    title text,
    link text,
    "desc" text,
    duration numeric(5,2),
    year integer,
    "scheduledAt" timestamp with time zone,
    "expiredAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "liveSeqId2019" integer,
    "liveSeqId2020" integer,
    level integer
);


--
-- Name: Task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Task_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Task_id_seq" OWNED BY public."Task".id;


--
-- Name: Test; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Test" (
    id integer NOT NULL,
    name character varying(255),
    description text,
    instructions text,
    "durationInMin" integer,
    "positiveMarks" integer,
    "negativeMarks" integer,
    "ownerId" integer,
    "ownerType" character varying(255),
    "creatorId" integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "startedAt" timestamp with time zone,
    "expiryAt" timestamp with time zone,
    "numQuestions" integer,
    syllabus text,
    free boolean DEFAULT false,
    sections json,
    "importUrl" character varying(255),
    "resultMsgHtml" text,
    "showAnswer" boolean DEFAULT true,
    year integer,
    exam public."enum_Test_exam",
    "pdfURL" text,
    "userId" integer,
    scholarship boolean DEFAULT false NOT NULL,
    "reviewAt" timestamp with time zone,
    "discussionEnd" timestamp with time zone,
    "seqId" integer DEFAULT 0 NOT NULL
);


--
-- Name: TestAttempt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TestAttempt" (
    id integer NOT NULL,
    "testId" integer,
    "userId" integer,
    "elapsedDurationInSec" integer DEFAULT 0,
    "currentQuestionOffset" integer DEFAULT 0,
    completed boolean DEFAULT false,
    "userAnswers" json,
    "userQuestionWiseDurationInSec" json,
    result json,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "visitedQuestions" json,
    "markedQuestions" json,
    "nextTargetScore" integer,
    "nextTargetDate" timestamp without time zone,
    "finishedAt" timestamp with time zone
);


--
-- Name: TestAttemptBackup506173; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TestAttemptBackup506173" (
    id integer,
    "testId" integer,
    "userId" integer,
    "elapsedDurationInSec" integer,
    "currentQuestionOffset" integer,
    completed boolean,
    "userAnswers" json,
    "userQuestionWiseDurationInSec" json,
    result json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "visitedQuestions" json,
    "markedQuestions" json,
    "nextTargetScore" integer,
    "nextTargetDate" timestamp without time zone
);


--
-- Name: TestAttemptCorrectQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."TestAttemptCorrectQuestion" AS
 SELECT (json_each_text.key)::integer AS "questionId",
    "TestAttempt".id AS "testAttemptId"
   FROM public."TestAttempt",
    public."Question",
    LATERAL json_each_text("TestAttempt"."userAnswers") json_each_text(key, value)
  WHERE (("Question".id = (json_each_text.key)::integer) AND ((json_each_text.value)::integer = "Question"."correctOptionIndex"));


--
-- Name: TestAttemptDetail; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."TestAttemptDetail" AS
 SELECT "TestAttempt".id,
    public."TestAttemptDetailFunc"("TestAttempt".id) AS "showAnswer"
   FROM public."TestAttempt"
  WHERE ("TestAttempt".completed = true);


--
-- Name: TestAttemptHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TestAttemptHistory" (
    "eventTime" timestamp(2) without time zone,
    "userId" integer,
    "testId" integer,
    "changedAnswers" jsonb
);


--
-- Name: TestAttemptIncorrectQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."TestAttemptIncorrectQuestion" AS
 SELECT (json_each_text.key)::integer AS "questionId",
    "TestAttempt".id AS "testAttemptId"
   FROM public."TestAttempt",
    public."Question",
    LATERAL json_each_text("TestAttempt"."userAnswers") json_each_text(key, value)
  WHERE (("Question".id = (json_each_text.key)::integer) AND ((json_each_text.value)::integer <> "Question"."correctOptionIndex"));


--
-- Name: TestAttemptPostmartem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TestAttemptPostmartem" (
    id integer NOT NULL,
    "questionId" integer NOT NULL,
    "userId" integer NOT NULL,
    "testAttemptId" integer NOT NULL,
    mistake character varying(255),
    action character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: TestAttemptPostmartem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TestAttemptPostmartem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TestAttemptPostmartem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TestAttemptPostmartem_id_seq" OWNED BY public."TestAttemptPostmartem".id;


--
-- Name: TestAttemptUnattemptedQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."TestAttemptUnattemptedQuestion" AS
 SELECT "TestQuestion"."questionId",
    "TestAttempt".id AS "testAttemptId"
   FROM public."TestQuestion",
    public."TestAttempt"
  WHERE (("TestAttempt"."testId" = "TestQuestion"."testId") AND (NOT ("TestQuestion"."questionId" IN ( SELECT ("UserAnswers".key)::integer AS key
           FROM json_each_text("TestAttempt"."userAnswers") "UserAnswers"(key, value)))));


--
-- Name: TestAttempt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TestAttempt_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TestAttempt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TestAttempt_id_seq" OWNED BY public."TestAttempt".id;


--
-- Name: TestQuestion20201130; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TestQuestion20201130" (
    id integer,
    "testId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "seqNum" integer
);


--
-- Name: TestQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TestQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TestQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TestQuestion_id_seq" OWNED BY public."TestQuestion".id;


--
-- Name: Test_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Test_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Test_id_seq" OWNED BY public."Test".id;


--
-- Name: TopicAsset; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."TopicAsset" AS
 SELECT row_number() OVER (ORDER BY "topicAsset"."assetId") AS id,
    "topicAsset"."assetId",
    "topicAsset"."topicId",
    "topicAsset"."ownerId",
    "topicAsset"."ownerType",
    "topicAsset"."assetType",
    "topicAsset"."position",
    "topicAsset".deleted,
    "topicAsset"."createdAt",
    "topicAsset"."updatedAt"
   FROM ( SELECT "ChapterVideo"."videoId" AS "assetId",
            "ChapterVideo"."chapterId" AS "topicId",
            "ChapterVideo"."chapterId" AS "ownerId",
            'Topic'::text AS "ownerType",
            'Video'::text AS "assetType",
            NULL::text AS "position",
            false AS deleted,
            "ChapterVideo"."createdAt",
            "ChapterVideo"."updatedAt"
           FROM public."ChapterVideo",
            public."SubjectChapter",
            public."Subject",
            public."Course"
          WHERE (("SubjectChapter"."chapterId" = "ChapterVideo"."chapterId") AND ("SubjectChapter".deleted = false) AND ("SubjectChapter"."subjectId" = "Subject".id) AND ("Course".id = "Subject"."courseId") AND ("Course".id = 8))
        UNION ALL
         SELECT "ChapterQuestion"."questionId" AS "assetId",
            "ChapterQuestion"."chapterId" AS "topicId",
            "ChapterQuestion"."chapterId" AS "ownerId",
            'Topic'::text AS "ownerType",
            'Question'::text AS "assetType",
            NULL::text AS "position",
            false AS deleted,
            "ChapterQuestion"."createdAt",
            "ChapterQuestion"."updatedAt"
           FROM public."ChapterQuestion",
            public."SubjectChapter",
            public."Subject",
            public."Course"
          WHERE (("SubjectChapter"."chapterId" = "ChapterQuestion"."chapterId") AND ("SubjectChapter".deleted = false) AND ("SubjectChapter"."subjectId" = "Subject".id) AND ("Course".id = "Subject"."courseId") AND ("Course".id = 8))
        UNION ALL
         SELECT "ChapterNote"."noteId" AS "assetId",
            "ChapterNote"."chapterId" AS "topicId",
            "ChapterNote"."chapterId" AS "ownerId",
            'Topic'::text AS "ownerType",
            'Note'::text AS "assetType",
            NULL::text AS "position",
            false AS deleted,
            "ChapterNote"."createdAt",
            "ChapterNote"."updatedAt"
           FROM public."ChapterNote",
            public."SubjectChapter",
            public."Subject",
            public."Course"
          WHERE (("SubjectChapter"."chapterId" = "ChapterNote"."chapterId") AND ("SubjectChapter".deleted = false) AND ("SubjectChapter"."subjectId" = "Subject".id) AND ("Course".id = "Subject"."courseId") AND ("Course".id = 8))) "topicAsset";


--
-- Name: TopicAssetOld; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TopicAssetOld" (
    id integer NOT NULL,
    "assetType" character varying(255),
    "assetId" integer,
    "topicId" integer,
    "position" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    deleted boolean DEFAULT false,
    "ownerId" integer NOT NULL,
    "ownerType" character varying(255) NOT NULL
);


--
-- Name: TopicAsset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TopicAsset_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TopicAsset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TopicAsset_id_seq" OWNED BY public."TopicAssetOld".id;


--
-- Name: TopicLeaderBoard; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."TopicLeaderBoard" AS
 SELECT "TopicLeaderBoardDataWithRank".id,
    "TopicLeaderBoardDataWithRank".rank,
    "TopicLeaderBoardDataWithRank"."userId",
    "TopicLeaderBoardDataWithRank"."topicId",
    "TopicLeaderBoardDataWithRank".score,
    "TopicLeaderBoardDataWithRank"."rankScore",
    "TopicLeaderBoardDataWithRank"."correctAnswerCount",
    "TopicLeaderBoardDataWithRank"."incorrectAnswerCount"
   FROM ( SELECT row_number() OVER () AS id,
            rank() OVER (PARTITION BY "TopicLeaderBoardDataRank"."topicId" ORDER BY "TopicLeaderBoardDataRank".score DESC) AS rank,
            "TopicLeaderBoardDataRank"."userId",
            "TopicLeaderBoardDataRank"."topicId",
            "TopicLeaderBoardDataRank".score,
            "TopicLeaderBoardDataRank"."rankScore",
            "TopicLeaderBoardDataRank"."correctAnswerCount",
            "TopicLeaderBoardDataRank"."incorrectAnswerCount"
           FROM ( SELECT "TopicLeaderBoardData"."userId",
                    "TopicLeaderBoardData"."topicId",
                    "TopicLeaderBoardData".score,
                    (("TopicLeaderBoardData".score * (("TopicLeaderBoardData"."correctAnswerCount" * 100) / ("TopicLeaderBoardData"."correctAnswerCount" + "TopicLeaderBoardData"."incorrectAnswerCount"))) / 100) AS "rankScore",
                    "TopicLeaderBoardData"."correctAnswerCount",
                    "TopicLeaderBoardData"."incorrectAnswerCount"
                   FROM ( SELECT "User".id AS "userId",
                            count(
                                CASE
                                    WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                                    ELSE NULL::integer
                                END) AS "correctAnswerCount",
                            count(
                                CASE
                                    WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                                    ELSE NULL::integer
                                END) AS "incorrectAnswerCount",
                            ((count(
                                CASE
                                    WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                                    ELSE NULL::integer
                                END) * 4) + (count(
                                CASE
                                    WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                                    ELSE NULL::integer
                                END) * '-1'::integer)) AS score,
                            "TopicQuestion"."topicId"
                           FROM public."Question",
                            public."Answer",
                            public."User",
                            public."TopicQuestion",
                            public."Topic",
                            public."Subject"
                          WHERE (("User".id = "Answer"."userId") AND ("Question".id = "Answer"."questionId") AND ("TopicQuestion".id = "Answer"."questionId") AND ("Question".deleted = false) AND ("TopicQuestion"."topicId" = "Topic".id) AND ("Topic"."subjectId" = "Subject".id) AND ("Subject"."courseId" = 8))
                          GROUP BY "User".id, "TopicQuestion"."topicId") "TopicLeaderBoardData"
                  WHERE (("TopicLeaderBoardData"."correctAnswerCount" <> 0) OR ("TopicLeaderBoardData"."incorrectAnswerCount" <> 0))) "TopicLeaderBoardDataRank") "TopicLeaderBoardDataWithRank"
  WITH NO DATA;


--
-- Name: Topic_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Topic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Topic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Topic_id_seq" OWNED BY public."Topic".id;


--
-- Name: UnattemptedQuestionVideo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."UnattemptedQuestionVideo" AS
 SELECT row_number() OVER (ORDER BY "Answer".id, "Video".id) AS id,
    "Test".id AS "testId",
    "Question".id AS "questionId",
    "TestAttempt".id AS "testAttemptId",
    "TestAttempt"."userId",
    "Video".id AS "videoId"
   FROM public."TestAttempt",
    public."Test",
    public."Question",
    public."VideoQuestion",
    public."Video",
    public."Answer",
    public."TestQuestion"
  WHERE (("Answer".id IS NULL) AND ("Test".id = "TestAttempt"."testId") AND ("VideoQuestion"."questionId" = "Question".id) AND ("Video".id = "VideoQuestion"."videoId") AND ("Question".id = "Answer"."questionId") AND ("Test".id = "TestQuestion"."testId"));


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role character varying DEFAULT 'support'::character varying NOT NULL,
    name character varying,
    "userId" integer,
    job_desc text
);


--
-- Name: UniqueDoubtAnswer; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."UniqueDoubtAnswer" AS
 SELECT _event.id,
    _event.content,
    _event."imgUrl",
    _event.accepted,
    _event."createdAt",
    _event."updatedAt",
    _event."doubtId",
    _event."userId",
    _event.deleted,
    _event.row_number
   FROM ( SELECT d.id,
            d.content,
            d."imgUrl",
            d.accepted,
            d."createdAt",
            d."updatedAt",
            d."doubtId",
            d."userId",
            d.deleted,
            row_number() OVER (PARTITION BY d."doubtId" ORDER BY d.id) AS row_number
           FROM (public."DoubtAnswer" d
             JOIN public."Doubt" a ON ((d."doubtId" = a.id)))
          WHERE (d."userId" IN ( SELECT admin_users."userId"
                   FROM public.admin_users
                  WHERE (((admin_users.role)::text = 'faculty'::text) OR ((admin_users.role)::text = 'superfaculty'::text))))) _event
  WHERE (_event.row_number = 1);


--
-- Name: UserCourse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserCourse" (
    id integer NOT NULL,
    "startedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "expiryAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    role public."enum_UserCourse_role" DEFAULT 'courseStudent'::public."enum_UserCourse_role",
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "courseId" integer NOT NULL,
    "userId" integer,
    "couponId" integer,
    trial boolean DEFAULT false,
    "invitationId" integer,
    "courseOfferId" integer,
    CONSTRAINT expiratcheck CHECK (("expiryAt" <= (CURRENT_TIMESTAMP + '6 years'::interval)))
);


--
-- Name: UserChapter; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."UserChapter" AS
 SELECT 1 AS id,
    "allChapters"."userId",
    "allChapters"."chapterId",
    "allChapters"."subjectId"
   FROM ( SELECT "User".id AS "userId",
            "Topic".id AS "chapterId",
            "Subject".id AS "subjectId"
           FROM public."User",
            public."UserCourse",
            public."Subject",
            public."Topic",
            public."SubjectChapter"
          WHERE (("User".id = "UserCourse"."userId") AND ("UserCourse"."courseId" = "Subject"."courseId") AND ("Subject".id = "SubjectChapter"."subjectId") AND ("SubjectChapter"."chapterId" = "Topic".id) AND ("UserCourse"."expiryAt" >= now()) AND ("SubjectChapter".deleted = false) AND ("Topic".free <> true))
        UNION
         SELECT NULL::integer AS "userId",
            "Topic".id AS "chapterId",
            "Subject".id AS "subjectId"
           FROM public."Subject",
            public."Topic",
            public."SubjectChapter"
          WHERE (("Topic".free = true) AND ("Subject".id = "SubjectChapter"."subjectId") AND ("SubjectChapter"."chapterId" = "Topic".id) AND ("SubjectChapter".deleted = false))) "allChapters";


--
-- Name: UserChapterStat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserChapterStat" (
    id integer NOT NULL,
    "userId" integer,
    "chapterId" integer,
    completed boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: UserChapterStat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserChapterStat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserChapterStat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserChapterStat_id_seq" OWNED BY public."UserChapterStat".id;


--
-- Name: UserClaim; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserClaim" (
    id integer NOT NULL,
    type character varying(255),
    value character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "userId" integer
);


--
-- Name: UserClaim_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserClaim_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserClaim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserClaim_id_seq" OWNED BY public."UserClaim".id;


--
-- Name: UserCourse177174; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserCourse177174" (
    id integer,
    "startedAt" timestamp with time zone,
    "expiryAt" timestamp with time zone,
    role public."enum_UserCourse_role",
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "courseId" integer,
    "userId" integer,
    "couponId" integer,
    trial boolean,
    "invitationId" integer,
    "courseOfferId" integer
);


--
-- Name: UserCourse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserCourse_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserCourse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserCourse_id_seq" OWNED BY public."UserCourse".id;


--
-- Name: UserDoubtStat; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."UserDoubtStat" AS
 SELECT "UserDoubtStatTemp".id,
    "UserDoubtStatTemp"."userId",
    "UserDoubtStatTemp"."doubtCount",
    COALESCE("UserDoubtStatTemp"."doubt7DaysCount", (0)::bigint) AS "doubt7DaysCount"
   FROM ( SELECT "User".id,
            "User".id AS "userId",
            doubt.doubt AS "doubtCount",
            doubt7."doubt7Count" AS "doubt7DaysCount"
           FROM ((public."User"
             JOIN ( SELECT "Doubt"."userId" AS ausrid,
                    count(*) AS doubt
                   FROM public."Doubt"
                  GROUP BY "Doubt"."userId") doubt ON (("User".id = doubt.ausrid)))
             LEFT JOIN ( SELECT "Doubt"."userId" AS aus7rid,
                    count(*) AS "doubt7Count"
                   FROM public."Doubt"
                  WHERE ("Doubt"."createdAt" > (CURRENT_DATE - '7 days'::interval))
                  GROUP BY "Doubt"."userId") doubt7 ON (("User".id = doubt7.aus7rid)))) "UserDoubtStatTemp"
  WITH NO DATA;


--
-- Name: UserDpp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserDpp" (
    id bigint NOT NULL,
    "testId" integer,
    "userId" integer,
    "subTopics" jsonb DEFAULT '[]'::jsonb,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- Name: UserDpp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserDpp_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserDpp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserDpp_id_seq" OWNED BY public."UserDpp".id;


--
-- Name: UserFlashCard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserFlashCard" (
    id bigint NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "flashCardId" integer NOT NULL
);


--
-- Name: UserFlashCard20200611; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserFlashCard20200611" (
    id bigint,
    "userId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer
);


--
-- Name: UserFlashCard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserFlashCard_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserFlashCard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserFlashCard_id_seq" OWNED BY public."UserFlashCard".id;


--
-- Name: UserHighlightedNote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserHighlightedNote" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "noteId" integer NOT NULL,
    content character varying(1000),
    color character varying(255),
    rangy character varying(255),
    "cfiRange" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "userNote" character varying(255),
    "pageNumber" integer,
    "pageId" character varying(255),
    uuid character varying(255),
    deleted boolean DEFAULT false
);


--
-- Name: UserHighlightedNote_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserHighlightedNote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserHighlightedNote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserHighlightedNote_id_seq" OWNED BY public."UserHighlightedNote".id;


--
-- Name: UserLogin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserLogin" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    expiry integer NOT NULL,
    platform character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: UserLogin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserLogin_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserLogin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserLogin_id_seq" OWNED BY public."UserLogin".id;


--
-- Name: UserNoteStat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserNoteStat" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "noteId" integer NOT NULL,
    "lastReadPage" integer,
    completed boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "bookId" character varying(255),
    "chapterHref" character varying(255),
    "usingId" boolean,
    value character varying(255),
    cfi character varying(255)
);


--
-- Name: UserNoteStat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserNoteStat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserNoteStat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserNoteStat_id_seq" OWNED BY public."UserNoteStat".id;


--
-- Name: UserProfile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserProfile" (
    id integer NOT NULL,
    "displayName" character varying(100),
    picture text,
    gender character varying(50),
    location character varying(100),
    website character varying(255),
    "firstName" character varying(100),
    "lastName" character varying(100),
    address character varying(100),
    city character varying(100),
    country character varying(100),
    intro character varying(1000),
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" integer,
    "defaultCourseId" integer,
    email character varying(255),
    phone character varying(20),
    "neetExamYear" integer,
    "weeklySchedule" json,
    "dailyStudyHours" numeric(4,2),
    "registrationNumber" character varying(255),
    dob date,
    "neetAdmitCard" character varying(255),
    "utmCampaignMedium" text,
    "utmCampaignSource" text,
    "utmCampaignLink" text,
    "utmAdNetwork" text,
    "utmCampaignTerm" text,
    "utmCampaignContent" text,
    "utmCampaignName" text,
    "campaignInfo" json,
    "allowVideoDownload" boolean DEFAULT false NOT NULL,
    "allowDeprecatedNcert" boolean DEFAULT false NOT NULL,
    "playerQuality" character varying,
    "playerSpeed" character varying
);


--
-- Name: UserVideoStat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserVideoStat" (
    id integer NOT NULL,
    "userId" integer,
    "videoId" integer,
    "lastPosition" double precision,
    completed boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isPaid" boolean DEFAULT true
);


--
-- Name: UserProfileAnalytic; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."UserProfileAnalytic" AS
 SELECT "UserProfileAnalyticTable".id,
    "UserProfileAnalyticTable"."userId",
    "UserProfileAnalyticTable"."ansCount",
    "UserProfileAnalyticTable"."ans7DaysCount",
    "UserProfileAnalyticTable"."testCount",
    "UserProfileAnalyticTable"."test7DaysCount",
    "UserProfileAnalyticTable"."videoCount",
    "UserProfileAnalyticTable"."video7DaysCount"
   FROM ( SELECT "User".id,
            "User".id AS "userId",
            ans.ans AS "ansCount",
            answer7."ans7Count" AS "ans7DaysCount",
            testatp."testId" AS "testCount",
            test7atp."test7Count" AS "test7DaysCount",
            "userV".vidid AS "videoCount",
            "user7V"."vid7Count" AS "video7DaysCount"
           FROM ((((((public."User"
             LEFT JOIN ( SELECT "Answer"."userId" AS ausrid,
                    count("Answer"."userAnswer") AS ans
                   FROM public."Answer"
                  GROUP BY "Answer"."userId") ans ON (("User".id = ans.ausrid)))
             LEFT JOIN ( SELECT "Answer"."userId" AS aus7rid,
                    count("Answer"."userAnswer") AS "ans7Count"
                   FROM public."Answer"
                  WHERE ("Answer"."createdAt" > (CURRENT_DATE - '7 days'::interval))
                  GROUP BY "Answer"."userId") answer7 ON (("User".id = answer7.aus7rid)))
             LEFT JOIN ( SELECT "TestAttempt"."userId" AS usrid,
                    count("TestAttempt"."testId") AS "testId"
                   FROM public."TestAttempt"
                  WHERE ("TestAttempt".completed = true)
                  GROUP BY "TestAttempt"."userId") testatp ON (("User".id = testatp.usrid)))
             LEFT JOIN ( SELECT "TestAttempt"."userId" AS usr7id,
                    count("TestAttempt"."testId") AS "test7Count"
                   FROM public."TestAttempt"
                  WHERE (("TestAttempt".completed = true) AND ("TestAttempt"."createdAt" > (CURRENT_DATE - '7 days'::interval)))
                  GROUP BY "TestAttempt"."userId") test7atp ON (("User".id = test7atp.usr7id)))
             LEFT JOIN ( SELECT "UserVideoStat"."userId" AS vidusrid,
                    count("UserVideoStat"."videoId") AS vidid
                   FROM public."UserVideoStat"
                  WHERE ("UserVideoStat".completed = true)
                  GROUP BY "UserVideoStat"."userId") "userV" ON (("User".id = "userV".vidusrid)))
             LEFT JOIN ( SELECT "UserVideoStat"."userId" AS vidusr7id,
                    count("UserVideoStat"."videoId") AS "vid7Count"
                   FROM public."UserVideoStat"
                  WHERE (("UserVideoStat".completed = true) AND ("UserVideoStat"."createdAt" > (CURRENT_DATE - '7 days'::interval)))
                  GROUP BY "UserVideoStat"."userId") "user7V" ON (("User".id = "user7V".vidusr7id)))
          ORDER BY ans.ans, testatp."testId", "userV".vidid, answer7."ans7Count", test7atp."test7Count", "user7V"."vid7Count") "UserProfileAnalyticTable"
  WITH NO DATA;


--
-- Name: UserProfile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserProfile_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserProfile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserProfile_id_seq" OWNED BY public."UserProfile".id;


--
-- Name: UserResult; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserResult" (
    id bigint NOT NULL,
    "userId" integer NOT NULL,
    name character varying,
    marks integer,
    air integer,
    state character varying,
    city character varying,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    year integer,
    "userImage" character varying
);


--
-- Name: UserResult_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserResult_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserResult_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserResult_id_seq" OWNED BY public."UserResult".id;


--
-- Name: UserScheduledTask; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserScheduledTask" (
    id integer NOT NULL,
    "userId" integer,
    "scheduledTaskId" integer,
    duration numeric(5,2),
    completed boolean DEFAULT false,
    started boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: UserScheduledTask_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserScheduledTask_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserScheduledTask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserScheduledTask_id_seq" OWNED BY public."UserScheduledTask".id;


--
-- Name: UserSectionStat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserSectionStat" (
    id integer NOT NULL,
    "userId" integer,
    "sectionId" integer,
    completed boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: UserSectionStat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserSectionStat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserSectionStat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserSectionStat_id_seq" OWNED BY public."UserSectionStat".id;


--
-- Name: UserTask; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserTask" (
    id integer NOT NULL,
    "userId" integer,
    "taskId" integer,
    duration numeric(5,2),
    "userDuration" numeric(5,2),
    completed boolean DEFAULT false,
    started boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: UserTaskProgress; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."UserTaskProgress" AS
 SELECT "UserTaskProgressTable".id,
    "UserTaskProgressTable"."userId",
    "UserTaskProgressTable"."totalTaskHour",
    "UserTaskProgressTable"."totalDuration",
    "UserTaskProgressTable"."scheduleId"
   FROM ( SELECT row_number() OVER (ORDER BY "totalProgress"."userId", ("totalProgress"."totalSum" / "totalDuration".sum) DESC) AS id,
            "totalProgress"."userId",
            "totalProgress"."totalSum" AS "totalTaskHour",
            "totalProgress"."userScheduleId" AS "userSchedule",
            "totalDuration".sum AS "totalDuration",
            "totalDuration"."scheduleId"
           FROM ( SELECT "ScheduleItemUser"."userId",
                    sum("ScheduleItem".hours) AS "totalSum",
                    "ScheduleItem"."scheduleId" AS "userScheduleId"
                   FROM public."ScheduleItemUser",
                    public."ScheduleItem",
                    public."Schedule"
                  WHERE (("ScheduleItemUser".completed = true) AND ("ScheduleItemUser"."scheduleItemId" = "ScheduleItem".id) AND ("Schedule".id = "ScheduleItem"."scheduleId") AND ("Schedule"."isActive" = true))
                  GROUP BY "ScheduleItemUser"."userId", "ScheduleItem"."scheduleId") "totalProgress",
            ( SELECT sum("ScheduleItem".hours) AS sum,
                    "ScheduleItem"."scheduleId"
                   FROM public."ScheduleItem"
                  GROUP BY "ScheduleItem"."scheduleId") "totalDuration") "UserTaskProgressTable"
  WHERE ("UserTaskProgressTable"."userSchedule" = "UserTaskProgressTable"."scheduleId")
  WITH NO DATA;


--
-- Name: UserTask_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserTask_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserTask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserTask_id_seq" OWNED BY public."UserTask".id;


--
-- Name: UserTodo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserTodo" (
    id bigint NOT NULL,
    "userId" integer NOT NULL,
    task_type integer NOT NULL,
    "subjectId" integer,
    "chapterId" integer,
    hours double precision NOT NULL,
    num_questions integer,
    hours_taken double precision,
    num_questions_practiced integer,
    completed boolean DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    student_response character varying,
    todo character varying
);


--
-- Name: UserTodo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserTodo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserTodo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserTodo_id_seq" OWNED BY public."UserTodo".id;


--
-- Name: UserVideo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."UserVideo" AS
 SELECT 1 AS id,
    "allVideos"."userId",
    "allVideos"."topicId",
    "allVideos"."videoId"
   FROM ( SELECT "User".id AS "userId",
            "Topic".id AS "topicId",
            "ChapterVideo"."videoId"
           FROM public."User",
            public."UserCourse",
            public."Subject",
            public."Topic",
            public."ChapterVideo",
            public."SubjectChapter"
          WHERE (("User".id = "UserCourse"."userId") AND ("UserCourse"."courseId" = "Subject"."courseId") AND ("Subject".id = "SubjectChapter"."subjectId") AND ("SubjectChapter"."chapterId" = "Topic".id) AND ("ChapterVideo"."chapterId" = "Topic".id) AND ("UserCourse"."expiryAt" >= now()) AND ("SubjectChapter".deleted = false) AND ("Topic".free <> true))
        UNION
         SELECT NULL::integer AS "userId",
            "Topic".id AS "topicId",
            "ChapterVideo"."videoId"
           FROM public."Subject",
            public."Topic",
            public."ChapterVideo"
          WHERE (("Topic".free = true) AND ("ChapterVideo"."chapterId" = "Topic".id))) "allVideos";


--
-- Name: UserVideoStat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserVideoStat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserVideoStat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserVideoStat_id_seq" OWNED BY public."UserVideoStat".id;


--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."User_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- Name: Video20200528; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Video20200528" (
    id integer,
    name character varying(255),
    description text,
    url text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    thumbnail text,
    duration double precision,
    "seqId" integer,
    "youtubeUrl" character varying(255),
    language character varying(255),
    url2 character varying(255)
);


--
-- Name: Video20200620; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Video20200620" (
    id integer,
    name character varying(255),
    description text,
    url text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    thumbnail text,
    duration double precision,
    "seqId" integer,
    "youtubeUrl" character varying(255),
    language character varying(255),
    url2 character varying(255)
);


--
-- Name: Video20201102; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Video20201102" (
    id integer,
    name character varying(255),
    description text,
    url text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    thumbnail text,
    duration double precision,
    "seqId" integer,
    "youtubeUrl" character varying(255),
    language character varying(255),
    url2 character varying(255)
);


--
-- Name: Video20201119; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Video20201119" (
    id integer,
    name character varying(255),
    description text,
    url text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    thumbnail text,
    duration double precision,
    "seqId" integer,
    "youtubeUrl" character varying(255),
    language character varying(255),
    url2 character varying(255)
);


--
-- Name: Video20210610; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Video20210610" (
    id integer,
    name character varying(255),
    description text,
    url text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    thumbnail text,
    duration double precision,
    "seqId" integer,
    "youtubeUrl" character varying(255),
    language character varying(255),
    url2 text
);


--
-- Name: VideoAnnotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VideoAnnotation" (
    id integer NOT NULL,
    "annotationType" character varying(255),
    "annotationId" integer,
    "videoId" integer,
    "videoTimeStampInSeconds" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "videoTimeMS" integer NOT NULL
);


--
-- Name: VideoAnnotation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VideoAnnotation_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoAnnotation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VideoAnnotation_id_seq" OWNED BY public."VideoAnnotation".id;


--
-- Name: VideoLink; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VideoLink" (
    id integer NOT NULL,
    "videoId" integer NOT NULL,
    name character varying(255),
    url character varying(255),
    "time" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    description text
);


--
-- Name: VideoLink_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VideoLink_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoLink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VideoLink_id_seq" OWNED BY public."VideoLink".id;


--
-- Name: VideoQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VideoQuestion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VideoQuestion_id_seq" OWNED BY public."VideoQuestion".id;


--
-- Name: VideoSentence20210704; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VideoSentence20210704" (
    id bigint,
    "videoId" integer,
    "chapterId" integer,
    "sectionId" integer,
    sentence character varying,
    "timestampStart" double precision,
    "timestampEnd" double precision,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    sentence1 text
);


--
-- Name: VideoSentenceDetail; Type: VIEW; Schema: public; Owner: -
--

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
    public."Video"
  WHERE ("VideoSentence"."videoId" = "Video".id);


--
-- Name: VideoSentence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VideoSentence_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoSentence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VideoSentence_id_seq" OWNED BY public."VideoSentence".id;


--
-- Name: VideoSubTopic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VideoSubTopic" (
    id integer NOT NULL,
    "videoId" integer,
    "subTopicId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: VideoSubTopicQuestion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."VideoSubTopicQuestion" AS
SELECT
    NULL::integer AS id,
    NULL::integer AS "videoId",
    NULL::integer AS "questionId";


--
-- Name: VideoSubTopic_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VideoSubTopic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoSubTopic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VideoSubTopic_id_seq" OWNED BY public."VideoSubTopic".id;


--
-- Name: VideoTest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VideoTest" (
    id integer NOT NULL,
    "videoId" integer NOT NULL,
    "testId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: VideoTest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VideoTest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoTest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VideoTest_id_seq" OWNED BY public."VideoTest".id;


--
-- Name: Video_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Video_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Video_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Video_id_seq" OWNED BY public."Video".id;


--
-- Name: Vote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Vote" (
    id integer NOT NULL,
    "userId" integer,
    "ownerId" integer,
    "ownerType" character varying(255),
    vote boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Vote_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Vote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Vote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Vote_id_seq" OWNED BY public."Vote".id;


--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
    id bigint NOT NULL,
    namespace character varying,
    body text,
    resource_type character varying,
    resource_id bigint,
    author_type character varying,
    author_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: coach_question_dashboard; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.coach_question_dashboard AS
 SELECT "Answer".id,
    "Question"."correctOptionIndex" AS correct_option,
    "Question".id AS question_id,
    "Answer"."createdAt" AS on_day,
    "Answer"."userAnswer" AS user_answer,
    "Topic".name AS topic_name,
    "Topic".id AS topic_id,
    "Subject".name AS subject_name,
    "Subject".id AS subject_id,
    "User".id AS user_id,
    "Answer"."createdAt",
    "Answer"."updatedAt"
   FROM (((((public."User"
     JOIN public."Answer" ON (("Answer"."userId" = "User".id)))
     JOIN public."Question" ON (("Question".id = "Answer"."questionId")))
     JOIN public."ChapterQuestion" ON (("ChapterQuestion"."questionId" = "Question".id)))
     JOIN public."Topic" ON (("Topic".id = "ChapterQuestion"."chapterId")))
     JOIN public."Subject" ON (("Subject".id = "Topic"."subjectId")))
  WHERE (("Answer"."testAttemptId" IS NULL) AND ("Question".deleted = false));


--
-- Name: coach_video_dashboard; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.coach_video_dashboard AS
 SELECT "Video".id,
    "Video".name AS video_name,
    "UserVideoStat"."updatedAt" AS on_day,
    "Topic".name AS topic_name,
    "Topic".id AS topic_id,
    "Subject".name AS subject_name,
    "Subject".id AS subject_id,
    "User".id AS user_id,
    "UserVideoStat".completed,
    "UserVideoStat"."createdAt",
    "UserVideoStat"."updatedAt",
    "UserVideoStat"."lastPosition" AS pos
   FROM (((((public."User"
     JOIN public."UserVideoStat" ON (("UserVideoStat"."userId" = "User".id)))
     JOIN public."Video" ON (("Video".id = "UserVideoStat"."videoId")))
     JOIN public."ChapterVideo" ON (("ChapterVideo"."videoId" = "Video".id)))
     JOIN public."Topic" ON (("Topic".id = "ChapterVideo"."chapterId")))
     JOIN public."Subject" ON (("Subject".id = "Topic"."subjectId")));


--
-- Name: copychaptervideo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.copychaptervideo (
    id integer,
    "chapterId" integer,
    "videoId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: copyvideo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.copyvideo (
    id integer,
    name character varying(255),
    description text,
    url text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "creatorId" integer,
    thumbnail text,
    duration double precision,
    "seqId" integer,
    "youtubeUrl" character varying(255),
    language character varying(255)
);


--
-- Name: doubt_admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doubt_admins (
    id bigint NOT NULL,
    "doubtId" integer,
    admin_user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: doubt_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.doubt_admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doubt_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.doubt_admins_id_seq OWNED BY public.doubt_admins.id;


--
-- Name: doubt_chat_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doubt_chat_channels (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: doubt_chat_channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.doubt_chat_channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doubt_chat_channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.doubt_chat_channels_id_seq OWNED BY public.doubt_chat_channels.id;


--
-- Name: doubt_chat_doubt_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doubt_chat_doubt_answers (
    id bigint NOT NULL,
    doubt_chat_user_id bigint NOT NULL,
    doubt_chat_doubt_id bigint NOT NULL,
    content json NOT NULL,
    ancestry character varying,
    upvote_count integer DEFAULT 0,
    downvote_count integer DEFAULT 0,
    deleted boolean DEFAULT false,
    display_parent_id character varying,
    display_parent_position integer,
    children_count integer DEFAULT 0 NOT NULL,
    accepted_answer boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    cached_votes_total integer DEFAULT 0,
    cached_votes_score integer DEFAULT 0,
    cached_votes_up integer DEFAULT 0,
    cached_votes_down integer DEFAULT 0,
    cached_weighted_score integer DEFAULT 0,
    cached_weighted_total integer DEFAULT 0,
    cached_weighted_average double precision DEFAULT 0.0
);


--
-- Name: doubt_chat_doubt_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.doubt_chat_doubt_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doubt_chat_doubt_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.doubt_chat_doubt_answers_id_seq OWNED BY public.doubt_chat_doubt_answers.id;


--
-- Name: doubt_chat_doubts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doubt_chat_doubts (
    id bigint NOT NULL,
    doubt_chat_user_id bigint NOT NULL,
    doubt_chat_channel_id bigint NOT NULL,
    content json NOT NULL,
    upvote_count integer DEFAULT 0,
    downvote_count integer DEFAULT 0,
    deleted boolean DEFAULT false,
    doubt_answers_count integer DEFAULT 0 NOT NULL,
    accepted_doubt_answer_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    cached_votes_total integer DEFAULT 0,
    cached_votes_score integer DEFAULT 0,
    cached_votes_up integer DEFAULT 0,
    cached_votes_down integer DEFAULT 0,
    cached_weighted_score integer DEFAULT 0,
    cached_weighted_total integer DEFAULT 0,
    cached_weighted_average double precision DEFAULT 0.0
);


--
-- Name: doubt_chat_doubts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.doubt_chat_doubts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doubt_chat_doubts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.doubt_chat_doubts_id_seq OWNED BY public.doubt_chat_doubts.id;


--
-- Name: drupal_batch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_batch (
    bid bigint NOT NULL,
    token character varying(64) NOT NULL,
    "timestamp" integer NOT NULL,
    batch bytea,
    CONSTRAINT drupal_batch_bid_check CHECK ((bid >= 0))
);


--
-- Name: TABLE drupal_batch; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_batch IS 'Stores details about batches (processes that run in multiple HTTP requests).';


--
-- Name: COLUMN drupal_batch.bid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_batch.bid IS 'Primary Key: Unique batch ID.';


--
-- Name: COLUMN drupal_batch.token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_batch.token IS 'A string token generated against the current user''s session id and the batch id, used to ensure that only the user who submitted the batch can effectively access it.';


--
-- Name: COLUMN drupal_batch."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_batch."timestamp" IS 'A Unix timestamp indicating when this batch was submitted for processing. Stale batches are purged at cron time.';


--
-- Name: COLUMN drupal_batch.batch; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_batch.batch IS 'A serialized array containing the processing data for the batch.';


--
-- Name: drupal_block_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_block_content (
    id integer NOT NULL,
    revision_id bigint,
    type character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT drupal_block_content_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_block_content_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_block_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_block_content IS 'The base table for block_content entities.';


--
-- Name: COLUMN drupal_block_content.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content.type IS 'The ID of the target entity.';


--
-- Name: drupal_block_content__body; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_block_content__body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    body_value text NOT NULL,
    body_summary text,
    body_format character varying(255),
    CONSTRAINT drupal_block_content__body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_block_content__body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_block_content__body_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_block_content__body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_block_content__body IS 'Data storage for block_content field body.';


--
-- Name: COLUMN drupal_block_content__body.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content__body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_block_content__body.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content__body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_block_content__body.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content__body.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_block_content__body.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content__body.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_block_content__body.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content__body.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_block_content__body.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content__body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: drupal_block_content_field_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_block_content_field_data (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    type character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    info character varying(255),
    changed integer,
    reusable smallint,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT drupal_block_content_field_data_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_block_content_field_data_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_block_content_field_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_block_content_field_data IS 'The data table for block_content entities.';


--
-- Name: COLUMN drupal_block_content_field_data.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content_field_data.type IS 'The ID of the target entity.';


--
-- Name: drupal_block_content_field_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_block_content_field_revision (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    info character varying(255),
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT drupal_block_content_field_revision_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_block_content_field_revision_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_block_content_field_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_block_content_field_revision IS 'The revision data table for block_content entities.';


--
-- Name: drupal_block_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_block_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_block_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_block_content_id_seq OWNED BY public.drupal_block_content.id;


--
-- Name: drupal_block_content_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_block_content_revision (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    langcode character varying(12) NOT NULL,
    revision_user bigint,
    revision_created integer,
    revision_log text,
    revision_default smallint,
    CONSTRAINT drupal_block_content_revision_id_check1 CHECK ((id >= 0)),
    CONSTRAINT drupal_block_content_revision_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT drupal_block_content_revision_revision_user_check CHECK ((revision_user >= 0))
);


--
-- Name: TABLE drupal_block_content_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_block_content_revision IS 'The revision table for block_content entities.';


--
-- Name: COLUMN drupal_block_content_revision.revision_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content_revision.revision_user IS 'The ID of the target entity.';


--
-- Name: drupal_block_content_revision__body; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_block_content_revision__body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    body_value text NOT NULL,
    body_summary text,
    body_format character varying(255),
    CONSTRAINT drupal_block_content_revision__body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_block_content_revision__body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_block_content_revision__body_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_block_content_revision__body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_block_content_revision__body IS 'Revision archive storage for block_content field body.';


--
-- Name: COLUMN drupal_block_content_revision__body.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content_revision__body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_block_content_revision__body.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content_revision__body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_block_content_revision__body.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content_revision__body.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_block_content_revision__body.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content_revision__body.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_block_content_revision__body.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content_revision__body.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_block_content_revision__body.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_block_content_revision__body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: drupal_block_content_revision_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_block_content_revision_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_block_content_revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_block_content_revision_revision_id_seq OWNED BY public.drupal_block_content_revision.revision_id;


--
-- Name: drupal_cache_bootstrap; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_bootstrap (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_bootstrap; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_bootstrap IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_bootstrap.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_bootstrap.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_bootstrap.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_bootstrap.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_bootstrap.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_bootstrap.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_bootstrap.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_bootstrap.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_bootstrap.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_bootstrap.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_bootstrap.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_bootstrap.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_bootstrap.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_bootstrap.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_config (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_config IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_config.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_config.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_config.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_config.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_config.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_config.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_config.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_config.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_config.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_config.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_config.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_config.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_config.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_config.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_container; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_container (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_container; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_container IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_container.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_container.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_container.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_container.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_container.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_container.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_container.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_container.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_container.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_container.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_container.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_container.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_container.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_container.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_data (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_data IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_data.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_data.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_data.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_data.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_data.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_data.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_data.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_data.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_data.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_data.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_data.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_data.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_data.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_data.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_default; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_default (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_default; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_default IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_default.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_default.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_default.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_default.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_default.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_default.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_default.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_default.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_default.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_default.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_default.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_default.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_default.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_default.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_discovery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_discovery (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_discovery; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_discovery IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_discovery.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_discovery.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_discovery.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_discovery.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_discovery.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_discovery.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_discovery.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_discovery.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_discovery.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_discovery.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_discovery.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_discovery.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_discovery.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_discovery.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_dynamic_page_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_dynamic_page_cache (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_dynamic_page_cache; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_dynamic_page_cache IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_dynamic_page_cache.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_dynamic_page_cache.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_dynamic_page_cache.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_dynamic_page_cache.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_dynamic_page_cache.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_dynamic_page_cache.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_dynamic_page_cache.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_dynamic_page_cache.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_dynamic_page_cache.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_dynamic_page_cache.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_dynamic_page_cache.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_dynamic_page_cache.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_dynamic_page_cache.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_dynamic_page_cache.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_entity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_entity (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_entity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_entity IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_entity.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_entity.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_entity.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_entity.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_entity.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_entity.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_entity.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_entity.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_entity.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_entity.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_entity.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_entity.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_entity.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_entity.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_menu (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_menu; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_menu IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_menu.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_menu.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_menu.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_menu.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_menu.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_menu.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_menu.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_menu.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_menu.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_menu.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_menu.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_menu.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_menu.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_menu.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_page (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_page IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_page.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_page.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_page.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_page.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_page.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_page.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_page.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_page.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_page.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_page.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_page.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_page.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_page.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_page.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_render; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_render (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_render; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_render IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_render.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_render.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_render.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_render.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_render.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_render.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_render.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_render.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_render.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_render.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_render.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_render.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_render.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_render.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cache_toolbar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cache_toolbar (
    cid character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created numeric(14,3) DEFAULT 0 NOT NULL,
    serialized smallint DEFAULT 0 NOT NULL,
    tags text,
    checksum character varying(255) NOT NULL
);


--
-- Name: TABLE drupal_cache_toolbar; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cache_toolbar IS 'Storage for the cache API.';


--
-- Name: COLUMN drupal_cache_toolbar.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_toolbar.cid IS 'Primary Key: Unique cache ID.';


--
-- Name: COLUMN drupal_cache_toolbar.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_toolbar.data IS 'A collection of data to cache.';


--
-- Name: COLUMN drupal_cache_toolbar.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_toolbar.expire IS 'A Unix timestamp indicating when the cache entry should expire, or -1 for never.';


--
-- Name: COLUMN drupal_cache_toolbar.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_toolbar.created IS 'A timestamp with millisecond precision indicating when the cache entry was created.';


--
-- Name: COLUMN drupal_cache_toolbar.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_toolbar.serialized IS 'A flag to indicate whether content is serialized (1) or not (0).';


--
-- Name: COLUMN drupal_cache_toolbar.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_toolbar.tags IS 'Space-separated list of cache tags for this entry.';


--
-- Name: COLUMN drupal_cache_toolbar.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cache_toolbar.checksum IS 'The tag invalidation checksum when this entry was saved.';


--
-- Name: drupal_cachetags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_cachetags (
    tag character varying(255) DEFAULT ''::character varying NOT NULL,
    invalidations integer DEFAULT 0 NOT NULL
);


--
-- Name: TABLE drupal_cachetags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_cachetags IS 'Cache table for tracking cache tag invalidations.';


--
-- Name: COLUMN drupal_cachetags.tag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cachetags.tag IS 'Namespace-prefixed tag string.';


--
-- Name: COLUMN drupal_cachetags.invalidations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_cachetags.invalidations IS 'Number incremented when the tag is invalidated.';


--
-- Name: drupal_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_comment (
    cid integer NOT NULL,
    comment_type character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT drupal_comment_cid_check CHECK ((cid >= 0))
);


--
-- Name: TABLE drupal_comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_comment IS 'The base table for comment entities.';


--
-- Name: COLUMN drupal_comment.comment_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment.comment_type IS 'The ID of the target entity.';


--
-- Name: drupal_comment__comment_body; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_comment__comment_body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    comment_body_value text NOT NULL,
    comment_body_format character varying(255),
    CONSTRAINT drupal_comment__comment_body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_comment__comment_body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_comment__comment_body_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_comment__comment_body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_comment__comment_body IS 'Data storage for comment field comment_body.';


--
-- Name: COLUMN drupal_comment__comment_body.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment__comment_body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_comment__comment_body.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment__comment_body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_comment__comment_body.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment__comment_body.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_comment__comment_body.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment__comment_body.revision_id IS 'The entity revision id this data is attached to, which for an unversioned entity type is the same as the entity id';


--
-- Name: COLUMN drupal_comment__comment_body.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment__comment_body.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_comment__comment_body.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment__comment_body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: drupal_comment_cid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_comment_cid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_comment_cid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_comment_cid_seq OWNED BY public.drupal_comment.cid;


--
-- Name: drupal_comment_entity_statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_comment_entity_statistics (
    entity_id bigint DEFAULT 0 NOT NULL,
    entity_type character varying(32) DEFAULT 'node'::character varying NOT NULL,
    field_name character varying(32) DEFAULT ''::character varying NOT NULL,
    cid integer DEFAULT 0 NOT NULL,
    last_comment_timestamp integer DEFAULT 0 NOT NULL,
    last_comment_name character varying(60),
    last_comment_uid bigint DEFAULT 0 NOT NULL,
    comment_count bigint DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_comment_entity_statistics_comment_count_check CHECK ((comment_count >= 0)),
    CONSTRAINT drupal_comment_entity_statistics_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_comment_entity_statistics_last_comment_uid_check CHECK ((last_comment_uid >= 0))
);


--
-- Name: TABLE drupal_comment_entity_statistics; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_comment_entity_statistics IS 'Maintains statistics of entity and comments posts to show "new" and "updated" flags.';


--
-- Name: COLUMN drupal_comment_entity_statistics.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_entity_statistics.entity_id IS 'The entity_id of the entity for which the statistics are compiled.';


--
-- Name: COLUMN drupal_comment_entity_statistics.entity_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_entity_statistics.entity_type IS 'The entity_type of the entity to which this comment is a reply.';


--
-- Name: COLUMN drupal_comment_entity_statistics.field_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_entity_statistics.field_name IS 'The field_name of the field that was used to add this comment.';


--
-- Name: COLUMN drupal_comment_entity_statistics.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_entity_statistics.cid IS 'The drupal_comment.cid of the last comment.';


--
-- Name: COLUMN drupal_comment_entity_statistics.last_comment_timestamp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_entity_statistics.last_comment_timestamp IS 'The Unix timestamp of the last comment that was posted within this node, from drupal_comment.changed.';


--
-- Name: COLUMN drupal_comment_entity_statistics.last_comment_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_entity_statistics.last_comment_name IS 'The name of the latest author to post a comment on this node, from drupal_comment.name.';


--
-- Name: COLUMN drupal_comment_entity_statistics.last_comment_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_entity_statistics.last_comment_uid IS 'The user ID of the latest author to post a comment on this node, from drupal_comment.uid.';


--
-- Name: COLUMN drupal_comment_entity_statistics.comment_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_entity_statistics.comment_count IS 'The total number of comments on this entity.';


--
-- Name: drupal_comment_field_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_comment_field_data (
    cid bigint NOT NULL,
    comment_type character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    uid bigint NOT NULL,
    pid bigint,
    entity_id bigint,
    subject character varying(64),
    name character varying(60),
    mail character varying(254),
    homepage character varying(255),
    hostname character varying(128),
    created integer NOT NULL,
    changed integer,
    thread character varying(255) NOT NULL,
    entity_type character varying(32) NOT NULL,
    field_name character varying(32) NOT NULL,
    default_langcode smallint NOT NULL,
    CONSTRAINT drupal_comment_field_data_cid_check CHECK ((cid >= 0)),
    CONSTRAINT drupal_comment_field_data_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_comment_field_data_pid_check CHECK ((pid >= 0)),
    CONSTRAINT drupal_comment_field_data_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_comment_field_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_comment_field_data IS 'The data table for comment entities.';


--
-- Name: COLUMN drupal_comment_field_data.comment_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_field_data.comment_type IS 'The ID of the target entity.';


--
-- Name: COLUMN drupal_comment_field_data.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_field_data.uid IS 'The ID of the target entity.';


--
-- Name: COLUMN drupal_comment_field_data.pid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_field_data.pid IS 'The ID of the target entity.';


--
-- Name: COLUMN drupal_comment_field_data.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_comment_field_data.entity_id IS 'The ID of the target entity.';


--
-- Name: drupal_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_config (
    collection character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea
);


--
-- Name: TABLE drupal_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_config IS 'The base table for configuration data.';


--
-- Name: COLUMN drupal_config.collection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_config.collection IS 'Primary Key: Config object collection.';


--
-- Name: COLUMN drupal_config.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_config.name IS 'Primary Key: Config object name.';


--
-- Name: COLUMN drupal_config.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_config.data IS 'A serialized configuration object data.';


--
-- Name: drupal_file_managed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_file_managed (
    fid integer NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    uid bigint,
    filename character varying(255),
    uri character varying(255) NOT NULL,
    filemime character varying(255),
    filesize bigint,
    status smallint NOT NULL,
    created integer,
    changed integer NOT NULL,
    CONSTRAINT drupal_file_managed_fid_check CHECK ((fid >= 0)),
    CONSTRAINT drupal_file_managed_filesize_check CHECK ((filesize >= 0)),
    CONSTRAINT drupal_file_managed_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_file_managed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_file_managed IS 'The base table for file entities.';


--
-- Name: COLUMN drupal_file_managed.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_file_managed.uid IS 'The ID of the target entity.';


--
-- Name: drupal_file_managed_fid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_file_managed_fid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_file_managed_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_file_managed_fid_seq OWNED BY public.drupal_file_managed.fid;


--
-- Name: drupal_file_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_file_usage (
    fid bigint NOT NULL,
    module character varying(50) DEFAULT ''::character varying NOT NULL,
    type character varying(64) DEFAULT ''::character varying NOT NULL,
    id character varying(64) DEFAULT 0 NOT NULL,
    count bigint DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_file_usage_count_check CHECK ((count >= 0)),
    CONSTRAINT drupal_file_usage_fid_check CHECK ((fid >= 0))
);


--
-- Name: TABLE drupal_file_usage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_file_usage IS 'Track where a file is used.';


--
-- Name: COLUMN drupal_file_usage.fid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_file_usage.fid IS 'File ID.';


--
-- Name: COLUMN drupal_file_usage.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_file_usage.module IS 'The name of the module that is using the file.';


--
-- Name: COLUMN drupal_file_usage.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_file_usage.type IS 'The name of the object type in which the file is used.';


--
-- Name: COLUMN drupal_file_usage.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_file_usage.id IS 'The primary key of the object using the file.';


--
-- Name: COLUMN drupal_file_usage.count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_file_usage.count IS 'The number of times this file is used by this object.';


--
-- Name: drupal_h5p_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_content (
    id integer NOT NULL,
    library_id bigint,
    parameters text,
    filtered_parameters text,
    disabled_features integer,
    title character varying(255),
    authors text,
    source character varying(2083),
    year_from bigint,
    year_to bigint,
    license character varying(32),
    license_version character varying(10),
    changes text,
    license_extras text,
    author_comments text,
    default_language character varying(32),
    CONSTRAINT drupal_h5p_content_disabled_features_check CHECK ((disabled_features >= 0)),
    CONSTRAINT drupal_h5p_content_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_h5p_content_library_id_check CHECK ((library_id >= 0)),
    CONSTRAINT drupal_h5p_content_year_from_check CHECK ((year_from >= 0)),
    CONSTRAINT drupal_h5p_content_year_to_check CHECK ((year_to >= 0))
);


--
-- Name: TABLE drupal_h5p_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_content IS 'The base table for h5p_content entities.';


--
-- Name: drupal_h5p_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_h5p_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_h5p_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_h5p_content_id_seq OWNED BY public.drupal_h5p_content.id;


--
-- Name: drupal_h5p_content_libraries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_content_libraries (
    content_id bigint NOT NULL,
    library_id bigint NOT NULL,
    dependency_type character varying(31) DEFAULT 'preloaded'::character varying NOT NULL,
    drop_css integer DEFAULT 0 NOT NULL,
    weight bigint DEFAULT 999999 NOT NULL,
    CONSTRAINT drupal_h5p_content_libraries_content_id_check CHECK ((content_id >= 0)),
    CONSTRAINT drupal_h5p_content_libraries_drop_css_check CHECK ((drop_css >= 0)),
    CONSTRAINT drupal_h5p_content_libraries_library_id_check CHECK ((library_id >= 0)),
    CONSTRAINT drupal_h5p_content_libraries_weight_check CHECK ((weight >= 0))
);


--
-- Name: TABLE drupal_h5p_content_libraries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_content_libraries IS 'Stores information about what h5p uses what libraries.';


--
-- Name: COLUMN drupal_h5p_content_libraries.content_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_libraries.content_id IS 'The identifier of an H5P Content entity.';


--
-- Name: COLUMN drupal_h5p_content_libraries.library_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_libraries.library_id IS 'The identifier of an H5P Library used by the H5P Content';


--
-- Name: COLUMN drupal_h5p_content_libraries.dependency_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_libraries.dependency_type IS 'dynamic, preloaded or editor';


--
-- Name: COLUMN drupal_h5p_content_libraries.drop_css; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_libraries.drop_css IS '1 if the preloaded css from the dependency is to be excluded.';


--
-- Name: COLUMN drupal_h5p_content_libraries.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_libraries.weight IS 'Determines the order in which the preloaded libraries will be loaded';


--
-- Name: drupal_h5p_content_user_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_content_user_data (
    user_id bigint NOT NULL,
    content_main_id bigint NOT NULL,
    sub_content_id bigint NOT NULL,
    data_id character varying(127) NOT NULL,
    "timestamp" bigint NOT NULL,
    data text NOT NULL,
    preloaded integer,
    delete_on_content_change integer,
    CONSTRAINT drupal_h5p_content_user_data_content_main_id_check CHECK ((content_main_id >= 0)),
    CONSTRAINT drupal_h5p_content_user_data_delete_on_content_change_check CHECK ((delete_on_content_change >= 0)),
    CONSTRAINT drupal_h5p_content_user_data_preloaded_check CHECK ((preloaded >= 0)),
    CONSTRAINT drupal_h5p_content_user_data_sub_content_id_check CHECK ((sub_content_id >= 0)),
    CONSTRAINT drupal_h5p_content_user_data_timestamp_check CHECK (("timestamp" >= 0)),
    CONSTRAINT drupal_h5p_content_user_data_user_id_check CHECK ((user_id >= 0))
);


--
-- Name: TABLE drupal_h5p_content_user_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_content_user_data IS 'Stores user data about the content';


--
-- Name: COLUMN drupal_h5p_content_user_data.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_user_data.user_id IS 'The user identifier';


--
-- Name: COLUMN drupal_h5p_content_user_data.content_main_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_user_data.content_main_id IS 'The main identifier for the h5p content';


--
-- Name: COLUMN drupal_h5p_content_user_data.sub_content_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_user_data.sub_content_id IS 'The sub identifier for the h5p content';


--
-- Name: COLUMN drupal_h5p_content_user_data.data_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_user_data.data_id IS 'The data type identifier';


--
-- Name: COLUMN drupal_h5p_content_user_data."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_user_data."timestamp" IS 'What the time is';


--
-- Name: COLUMN drupal_h5p_content_user_data.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_user_data.data IS 'Contains the data saved';


--
-- Name: COLUMN drupal_h5p_content_user_data.preloaded; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_user_data.preloaded IS 'Indicates if the is to be preloaded';


--
-- Name: COLUMN drupal_h5p_content_user_data.delete_on_content_change; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_content_user_data.delete_on_content_change IS 'Indicates if the data is to be deleted when the content gets updated';


--
-- Name: drupal_h5p_counters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_counters (
    type character varying(63) NOT NULL,
    library_name character varying(127) NOT NULL,
    library_version character varying(31) NOT NULL,
    num bigint NOT NULL,
    CONSTRAINT drupal_h5p_counters_num_check CHECK ((num >= 0))
);


--
-- Name: TABLE drupal_h5p_counters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_counters IS 'Global counters for the H5P system';


--
-- Name: COLUMN drupal_h5p_counters.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_counters.type IS 'Type of counter';


--
-- Name: COLUMN drupal_h5p_counters.library_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_counters.library_name IS 'Library';


--
-- Name: COLUMN drupal_h5p_counters.library_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_counters.library_version IS 'Version of library';


--
-- Name: COLUMN drupal_h5p_counters.num; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_counters.num IS 'Number value of counter';


--
-- Name: drupal_h5p_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_events (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    created_at integer NOT NULL,
    type character varying(63) NOT NULL,
    sub_type character varying(63) NOT NULL,
    content_id bigint NOT NULL,
    content_title character varying(255) NOT NULL,
    library_name character varying(127) NOT NULL,
    library_version character varying(31) NOT NULL,
    CONSTRAINT drupal_h5p_events_content_id_check CHECK ((content_id >= 0)),
    CONSTRAINT drupal_h5p_events_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_h5p_events_user_id_check CHECK ((user_id >= 0))
);


--
-- Name: TABLE drupal_h5p_events; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_events IS 'Keeps track of what happens in the H5P system';


--
-- Name: COLUMN drupal_h5p_events.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.id IS 'The unique event identifier';


--
-- Name: COLUMN drupal_h5p_events.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.user_id IS 'User id';


--
-- Name: COLUMN drupal_h5p_events.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.created_at IS 'Time of the event';


--
-- Name: COLUMN drupal_h5p_events.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.type IS 'Type of event';


--
-- Name: COLUMN drupal_h5p_events.sub_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.sub_type IS 'Sub type of event';


--
-- Name: COLUMN drupal_h5p_events.content_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.content_id IS 'Content id';


--
-- Name: COLUMN drupal_h5p_events.content_title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.content_title IS 'Content title';


--
-- Name: COLUMN drupal_h5p_events.library_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.library_name IS 'Library name';


--
-- Name: COLUMN drupal_h5p_events.library_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_events.library_version IS 'Version of library';


--
-- Name: drupal_h5p_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_h5p_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_h5p_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_h5p_events_id_seq OWNED BY public.drupal_h5p_events.id;


--
-- Name: drupal_h5p_libraries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_libraries (
    library_id integer NOT NULL,
    machine_name character varying(127) DEFAULT ''::character varying NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    major_version bigint NOT NULL,
    minor_version bigint NOT NULL,
    patch_version bigint NOT NULL,
    runnable integer DEFAULT 1 NOT NULL,
    fullscreen integer DEFAULT 0 NOT NULL,
    embed_types character varying(255) DEFAULT ''::character varying NOT NULL,
    preloaded_js text,
    preloaded_css text,
    drop_library_css text,
    semantics text NOT NULL,
    restricted integer DEFAULT 0 NOT NULL,
    tutorial_url character varying(1000),
    has_icon integer DEFAULT 0 NOT NULL,
    add_to text,
    metadata_settings text,
    CONSTRAINT drupal_h5p_libraries_fullscreen_check CHECK ((fullscreen >= 0)),
    CONSTRAINT drupal_h5p_libraries_has_icon_check CHECK ((has_icon >= 0)),
    CONSTRAINT drupal_h5p_libraries_library_id_check CHECK ((library_id >= 0)),
    CONSTRAINT drupal_h5p_libraries_major_version_check CHECK ((major_version >= 0)),
    CONSTRAINT drupal_h5p_libraries_minor_version_check CHECK ((minor_version >= 0)),
    CONSTRAINT drupal_h5p_libraries_patch_version_check CHECK ((patch_version >= 0)),
    CONSTRAINT drupal_h5p_libraries_restricted_check CHECK ((restricted >= 0)),
    CONSTRAINT drupal_h5p_libraries_runnable_check CHECK ((runnable >= 0))
);


--
-- Name: TABLE drupal_h5p_libraries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_libraries IS 'Stores information about what h5p uses what libraries.';


--
-- Name: COLUMN drupal_h5p_libraries.library_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.library_id IS 'Primary Key: The id of the library.';


--
-- Name: COLUMN drupal_h5p_libraries.machine_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.machine_name IS 'The library machine name';


--
-- Name: COLUMN drupal_h5p_libraries.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.title IS 'The human readable name of this library';


--
-- Name: COLUMN drupal_h5p_libraries.major_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.major_version IS 'The version of this library';


--
-- Name: COLUMN drupal_h5p_libraries.minor_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.minor_version IS 'The minor version of this library';


--
-- Name: COLUMN drupal_h5p_libraries.patch_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.patch_version IS 'The patch version of this library';


--
-- Name: COLUMN drupal_h5p_libraries.runnable; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.runnable IS 'Whether or not this library is executable.';


--
-- Name: COLUMN drupal_h5p_libraries.fullscreen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.fullscreen IS 'Indicates if this library can be opened in fullscreen.';


--
-- Name: COLUMN drupal_h5p_libraries.embed_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.embed_types IS 'The allowed embed types for this library as a comma separated list';


--
-- Name: COLUMN drupal_h5p_libraries.preloaded_js; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.preloaded_js IS 'The preloaded js for this library as a comma separated list';


--
-- Name: COLUMN drupal_h5p_libraries.preloaded_css; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.preloaded_css IS 'The preloaded css for this library as a comma separated list';


--
-- Name: COLUMN drupal_h5p_libraries.drop_library_css; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.drop_library_css IS 'List of libraries that should not have CSS included if this library is used. Comma separated list.';


--
-- Name: COLUMN drupal_h5p_libraries.semantics; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.semantics IS 'The semantics definition in json format';


--
-- Name: COLUMN drupal_h5p_libraries.restricted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.restricted IS 'Restricts the ability to create new content using this library.';


--
-- Name: COLUMN drupal_h5p_libraries.tutorial_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.tutorial_url IS 'URL to a tutorial for this library';


--
-- Name: COLUMN drupal_h5p_libraries.has_icon; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.has_icon IS 'Whether or not this library contains an icon.svg';


--
-- Name: COLUMN drupal_h5p_libraries.add_to; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.add_to IS 'Plugin configuration data';


--
-- Name: COLUMN drupal_h5p_libraries.metadata_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries.metadata_settings IS 'Metadata settings';


--
-- Name: drupal_h5p_libraries_hub_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_libraries_hub_cache (
    id integer NOT NULL,
    machine_name character varying(127) DEFAULT ''::character varying NOT NULL,
    major_version bigint NOT NULL,
    minor_version bigint NOT NULL,
    patch_version bigint NOT NULL,
    h5p_major_version bigint,
    h5p_minor_version bigint,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    summary text NOT NULL,
    description text NOT NULL,
    icon character varying(511) DEFAULT ''::character varying NOT NULL,
    created_at integer NOT NULL,
    updated_at integer NOT NULL,
    is_recommended integer DEFAULT 1 NOT NULL,
    popularity bigint DEFAULT 0 NOT NULL,
    screenshots text,
    license text,
    example character varying(511) DEFAULT ''::character varying NOT NULL,
    tutorial character varying(511),
    keywords text,
    categories text,
    owner character varying(511),
    CONSTRAINT drupal_h5p_libraries_hub_cache_h5p_major_version_check CHECK ((h5p_major_version >= 0)),
    CONSTRAINT drupal_h5p_libraries_hub_cache_h5p_minor_version_check CHECK ((h5p_minor_version >= 0)),
    CONSTRAINT drupal_h5p_libraries_hub_cache_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_h5p_libraries_hub_cache_is_recommended_check CHECK ((is_recommended >= 0)),
    CONSTRAINT drupal_h5p_libraries_hub_cache_major_version_check CHECK ((major_version >= 0)),
    CONSTRAINT drupal_h5p_libraries_hub_cache_minor_version_check CHECK ((minor_version >= 0)),
    CONSTRAINT drupal_h5p_libraries_hub_cache_patch_version_check CHECK ((patch_version >= 0)),
    CONSTRAINT drupal_h5p_libraries_hub_cache_popularity_check CHECK ((popularity >= 0))
);


--
-- Name: TABLE drupal_h5p_libraries_hub_cache; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_libraries_hub_cache IS 'Stores information about what h5p uses what libraries.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.id IS 'Primary Key: The id of the library.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.machine_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.machine_name IS 'The library machine name';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.major_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.major_version IS 'The version of this library';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.minor_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.minor_version IS 'The minor version of this library';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.patch_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.patch_version IS 'The patch version of this library';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.h5p_major_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.h5p_major_version IS 'The major version required of H5P core.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.h5p_minor_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.h5p_minor_version IS 'The minor version required of H5P core.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.title IS 'The human readable name of this library';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.summary IS 'Short description of library.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.description IS 'Long description of library.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.icon; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.icon IS 'URL to icon.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.created_at IS 'Time that the library was uploaded.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.updated_at IS 'Time that the library had its latest update.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.is_recommended; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.is_recommended IS 'Whether the library is recommended by the HUB moderators.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.popularity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.popularity IS 'How many times the library has been downloaded.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.screenshots; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.screenshots IS 'Screenshot URLs json encoded';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.license; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.license IS 'Library license(s) json encoded';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.example; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.example IS 'URL to example content for this library.';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.tutorial; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.tutorial IS 'Tutorial URL';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.keywords; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.keywords IS 'Keywords for library json encoded';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.categories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.categories IS 'Categories for library json encoded';


--
-- Name: COLUMN drupal_h5p_libraries_hub_cache.owner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_hub_cache.owner IS 'Owner of the library';


--
-- Name: drupal_h5p_libraries_hub_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_h5p_libraries_hub_cache_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_h5p_libraries_hub_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_h5p_libraries_hub_cache_id_seq OWNED BY public.drupal_h5p_libraries_hub_cache.id;


--
-- Name: drupal_h5p_libraries_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_libraries_languages (
    library_id bigint NOT NULL,
    language_code character varying(31) NOT NULL,
    language_json text NOT NULL,
    CONSTRAINT drupal_h5p_libraries_languages_library_id_check CHECK ((library_id >= 0))
);


--
-- Name: TABLE drupal_h5p_libraries_languages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_libraries_languages IS 'Stores translations for the languages.';


--
-- Name: COLUMN drupal_h5p_libraries_languages.library_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_languages.library_id IS 'Primary Key: The id of a h5p library.';


--
-- Name: COLUMN drupal_h5p_libraries_languages.language_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_languages.language_code IS 'Primary Key: The language code.';


--
-- Name: COLUMN drupal_h5p_libraries_languages.language_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_languages.language_json IS 'The translations defined in json format';


--
-- Name: drupal_h5p_libraries_libraries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_libraries_libraries (
    library_id bigint NOT NULL,
    required_library_id bigint NOT NULL,
    dependency_type character varying(31) NOT NULL,
    CONSTRAINT drupal_h5p_libraries_libraries_library_id_check CHECK ((library_id >= 0)),
    CONSTRAINT drupal_h5p_libraries_libraries_required_library_id_check CHECK ((required_library_id >= 0))
);


--
-- Name: TABLE drupal_h5p_libraries_libraries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_libraries_libraries IS 'Stores information about library dependencies.';


--
-- Name: COLUMN drupal_h5p_libraries_libraries.library_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_libraries.library_id IS 'Primary Key: The id of a h5p library.';


--
-- Name: COLUMN drupal_h5p_libraries_libraries.required_library_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_libraries.required_library_id IS 'Primary Key: The id of a h5p library.';


--
-- Name: COLUMN drupal_h5p_libraries_libraries.dependency_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_libraries_libraries.dependency_type IS 'preloaded, dynamic, or editor';


--
-- Name: drupal_h5p_libraries_library_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_h5p_libraries_library_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_h5p_libraries_library_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_h5p_libraries_library_id_seq OWNED BY public.drupal_h5p_libraries.library_id;


--
-- Name: drupal_h5p_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_h5p_points (
    content_id bigint NOT NULL,
    uid bigint NOT NULL,
    started bigint NOT NULL,
    finished bigint DEFAULT 0 NOT NULL,
    points bigint,
    max_points bigint,
    CONSTRAINT drupal_h5p_points_content_id_check CHECK ((content_id >= 0)),
    CONSTRAINT drupal_h5p_points_finished_check CHECK ((finished >= 0)),
    CONSTRAINT drupal_h5p_points_max_points_check CHECK ((max_points >= 0)),
    CONSTRAINT drupal_h5p_points_points_check CHECK ((points >= 0)),
    CONSTRAINT drupal_h5p_points_started_check CHECK ((started >= 0)),
    CONSTRAINT drupal_h5p_points_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_h5p_points; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_h5p_points IS 'Stores user statistics.';


--
-- Name: COLUMN drupal_h5p_points.content_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_points.content_id IS 'Primary Key: The unique identifier for this node.';


--
-- Name: COLUMN drupal_h5p_points.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_points.uid IS 'Primary Key: The id for the user answering this H5P.';


--
-- Name: COLUMN drupal_h5p_points.started; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_points.started IS 'When the user started on the interaction';


--
-- Name: COLUMN drupal_h5p_points.finished; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_points.finished IS 'When the user submitted the result';


--
-- Name: COLUMN drupal_h5p_points.points; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_points.points IS 'The users score';


--
-- Name: COLUMN drupal_h5p_points.max_points; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_h5p_points.max_points IS 'The maximum score for this test';


--
-- Name: drupal_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_history (
    uid integer DEFAULT 0 NOT NULL,
    nid bigint DEFAULT 0 NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_history_nid_check CHECK ((nid >= 0))
);


--
-- Name: TABLE drupal_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_history IS 'A record of which drupal_users have read which drupal_nodes.';


--
-- Name: COLUMN drupal_history.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_history.uid IS 'The drupal_users.uid that read the drupal_node nid.';


--
-- Name: COLUMN drupal_history.nid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_history.nid IS 'The drupal_node.nid that was read.';


--
-- Name: COLUMN drupal_history."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_history."timestamp" IS 'The Unix timestamp at which the read occurred.';


--
-- Name: drupal_key_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_key_value (
    collection character varying(128) DEFAULT ''::character varying NOT NULL,
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    value bytea NOT NULL
);


--
-- Name: TABLE drupal_key_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_key_value IS 'Generic key-value storage table. See the state system for an example.';


--
-- Name: COLUMN drupal_key_value.collection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_key_value.collection IS 'A named collection of key and value pairs.';


--
-- Name: COLUMN drupal_key_value.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_key_value.name IS 'The key of the key-value pair. As KEY is a SQL reserved keyword, name was chosen instead.';


--
-- Name: COLUMN drupal_key_value.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_key_value.value IS 'The value.';


--
-- Name: drupal_key_value_expire; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_key_value_expire (
    collection character varying(128) DEFAULT ''::character varying NOT NULL,
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    value bytea NOT NULL,
    expire integer DEFAULT 2147483647 NOT NULL
);


--
-- Name: TABLE drupal_key_value_expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_key_value_expire IS 'Generic key/value storage table with an expiration.';


--
-- Name: COLUMN drupal_key_value_expire.collection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_key_value_expire.collection IS 'A named collection of key and value pairs.';


--
-- Name: COLUMN drupal_key_value_expire.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_key_value_expire.name IS 'The key of the key/value pair.';


--
-- Name: COLUMN drupal_key_value_expire.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_key_value_expire.value IS 'The value of the key/value pair.';


--
-- Name: COLUMN drupal_key_value_expire.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_key_value_expire.expire IS 'The time since Unix epoch in seconds when this item expires. Defaults to the maximum possible time.';


--
-- Name: drupal_menu_link_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_menu_link_content (
    id integer NOT NULL,
    revision_id bigint,
    bundle character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT drupal_menu_link_content_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_menu_link_content_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_menu_link_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_menu_link_content IS 'The base table for menu_link_content entities.';


--
-- Name: drupal_menu_link_content_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_menu_link_content_data (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    bundle character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    enabled smallint NOT NULL,
    title character varying(255),
    description character varying(255),
    menu_name character varying(255),
    link__uri character varying(2048),
    link__title character varying(255),
    link__options bytea,
    external smallint,
    rediscover smallint,
    weight integer,
    expanded smallint,
    parent character varying(255),
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT drupal_menu_link_content_data_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_menu_link_content_data_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_menu_link_content_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_menu_link_content_data IS 'The data table for menu_link_content entities.';


--
-- Name: COLUMN drupal_menu_link_content_data.link__uri; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_link_content_data.link__uri IS 'The URI of the link.';


--
-- Name: COLUMN drupal_menu_link_content_data.link__title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_link_content_data.link__title IS 'The link text.';


--
-- Name: COLUMN drupal_menu_link_content_data.link__options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_link_content_data.link__options IS 'Serialized array of options for the link.';


--
-- Name: drupal_menu_link_content_field_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_menu_link_content_field_revision (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    enabled smallint NOT NULL,
    title character varying(255),
    description character varying(255),
    link__uri character varying(2048),
    link__title character varying(255),
    link__options bytea,
    external smallint,
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT drupal_menu_link_content_field_revision_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_menu_link_content_field_revision_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_menu_link_content_field_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_menu_link_content_field_revision IS 'The revision data table for menu_link_content entities.';


--
-- Name: COLUMN drupal_menu_link_content_field_revision.link__uri; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_link_content_field_revision.link__uri IS 'The URI of the link.';


--
-- Name: COLUMN drupal_menu_link_content_field_revision.link__title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_link_content_field_revision.link__title IS 'The link text.';


--
-- Name: COLUMN drupal_menu_link_content_field_revision.link__options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_link_content_field_revision.link__options IS 'Serialized array of options for the link.';


--
-- Name: drupal_menu_link_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_menu_link_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_menu_link_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_menu_link_content_id_seq OWNED BY public.drupal_menu_link_content.id;


--
-- Name: drupal_menu_link_content_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_menu_link_content_revision (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    langcode character varying(12) NOT NULL,
    revision_user bigint,
    revision_created integer,
    revision_log_message text,
    revision_default smallint,
    CONSTRAINT drupal_menu_link_content_revision_id_check1 CHECK ((id >= 0)),
    CONSTRAINT drupal_menu_link_content_revision_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT drupal_menu_link_content_revision_revision_user_check CHECK ((revision_user >= 0))
);


--
-- Name: TABLE drupal_menu_link_content_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_menu_link_content_revision IS 'The revision table for menu_link_content entities.';


--
-- Name: COLUMN drupal_menu_link_content_revision.revision_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_link_content_revision.revision_user IS 'The ID of the target entity.';


--
-- Name: drupal_menu_link_content_revision_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_menu_link_content_revision_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_menu_link_content_revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_menu_link_content_revision_revision_id_seq OWNED BY public.drupal_menu_link_content_revision.revision_id;


--
-- Name: drupal_menu_tree; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_menu_tree (
    menu_name character varying(32) DEFAULT ''::character varying NOT NULL,
    mlid integer NOT NULL,
    id character varying(255) NOT NULL,
    parent character varying(255) DEFAULT ''::character varying NOT NULL,
    route_name character varying(255),
    route_param_key character varying(255),
    route_parameters bytea,
    url character varying(255) DEFAULT ''::character varying NOT NULL,
    title bytea,
    description bytea,
    class text,
    options bytea,
    provider character varying(50) DEFAULT 'system'::character varying NOT NULL,
    enabled smallint DEFAULT 1 NOT NULL,
    discovered smallint DEFAULT 0 NOT NULL,
    expanded smallint DEFAULT 0 NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    metadata bytea,
    has_children smallint DEFAULT 0 NOT NULL,
    depth smallint DEFAULT 0 NOT NULL,
    p1 bigint DEFAULT 0 NOT NULL,
    p2 bigint DEFAULT 0 NOT NULL,
    p3 bigint DEFAULT 0 NOT NULL,
    p4 bigint DEFAULT 0 NOT NULL,
    p5 bigint DEFAULT 0 NOT NULL,
    p6 bigint DEFAULT 0 NOT NULL,
    p7 bigint DEFAULT 0 NOT NULL,
    p8 bigint DEFAULT 0 NOT NULL,
    p9 bigint DEFAULT 0 NOT NULL,
    form_class character varying(255),
    CONSTRAINT drupal_menu_tree_mlid_check CHECK ((mlid >= 0)),
    CONSTRAINT drupal_menu_tree_p1_check CHECK ((p1 >= 0)),
    CONSTRAINT drupal_menu_tree_p2_check CHECK ((p2 >= 0)),
    CONSTRAINT drupal_menu_tree_p3_check CHECK ((p3 >= 0)),
    CONSTRAINT drupal_menu_tree_p4_check CHECK ((p4 >= 0)),
    CONSTRAINT drupal_menu_tree_p5_check CHECK ((p5 >= 0)),
    CONSTRAINT drupal_menu_tree_p6_check CHECK ((p6 >= 0)),
    CONSTRAINT drupal_menu_tree_p7_check CHECK ((p7 >= 0)),
    CONSTRAINT drupal_menu_tree_p8_check CHECK ((p8 >= 0)),
    CONSTRAINT drupal_menu_tree_p9_check CHECK ((p9 >= 0))
);


--
-- Name: TABLE drupal_menu_tree; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_menu_tree IS 'Contains the menu tree hierarchy.';


--
-- Name: COLUMN drupal_menu_tree.menu_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.menu_name IS 'The menu name. All links with the same menu name (such as ''tools'') are part of the same menu.';


--
-- Name: COLUMN drupal_menu_tree.mlid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.mlid IS 'The menu link ID (mlid) is the integer primary key.';


--
-- Name: COLUMN drupal_menu_tree.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.id IS 'Unique machine name: the plugin ID.';


--
-- Name: COLUMN drupal_menu_tree.parent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.parent IS 'The plugin ID for the parent of this link.';


--
-- Name: COLUMN drupal_menu_tree.route_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.route_name IS 'The machine name of a defined Symfony Route this menu item represents.';


--
-- Name: COLUMN drupal_menu_tree.route_param_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.route_param_key IS 'An encoded string of route parameters for loading by route.';


--
-- Name: COLUMN drupal_menu_tree.route_parameters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.route_parameters IS 'Serialized array of route parameters of this menu link.';


--
-- Name: COLUMN drupal_menu_tree.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.url IS 'The external path this link points to (when not using a route).';


--
-- Name: COLUMN drupal_menu_tree.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.title IS 'The serialized title for the link. May be a TranslatableMarkup.';


--
-- Name: COLUMN drupal_menu_tree.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.description IS 'The serialized description of this link - used for admin pages and title attribute. May be a TranslatableMarkup.';


--
-- Name: COLUMN drupal_menu_tree.class; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.class IS 'The class for this link plugin.';


--
-- Name: COLUMN drupal_menu_tree.options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.options IS 'A serialized array of URL options, such as a query string or HTML attributes.';


--
-- Name: COLUMN drupal_menu_tree.provider; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.provider IS 'The name of the module that generated this link.';


--
-- Name: COLUMN drupal_menu_tree.enabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.enabled IS 'A flag for whether the link should be rendered in menus. (0 = a disabled menu item that may be shown on admin screens, 1 = a normal, visible link)';


--
-- Name: COLUMN drupal_menu_tree.discovered; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.discovered IS 'A flag for whether the link was discovered, so can be purged on rebuild';


--
-- Name: COLUMN drupal_menu_tree.expanded; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.expanded IS 'Flag for whether this link should be rendered as expanded in menus - expanded links always have their child links displayed, instead of only when the link is in the active trail (1 = expanded, 0 = not expanded)';


--
-- Name: COLUMN drupal_menu_tree.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.weight IS 'Link weight among links in the same menu at the same depth.';


--
-- Name: COLUMN drupal_menu_tree.metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.metadata IS 'A serialized array of data that may be used by the plugin instance.';


--
-- Name: COLUMN drupal_menu_tree.has_children; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.has_children IS 'Flag indicating whether any enabled links have this link as a parent (1 = enabled children exist, 0 = no enabled children).';


--
-- Name: COLUMN drupal_menu_tree.depth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.depth IS 'The depth relative to the top level. A link with empty parent will have depth == 1.';


--
-- Name: COLUMN drupal_menu_tree.p1; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p1 IS 'The first mlid in the materialized path. If N = depth, then pN must equal the mlid. If depth > 1 then p(N-1) must equal the parent link mlid. All pX where X > depth must equal zero. The columns p1 .. p9 are also called the parents.';


--
-- Name: COLUMN drupal_menu_tree.p2; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p2 IS 'The second mlid in the materialized path. See p1.';


--
-- Name: COLUMN drupal_menu_tree.p3; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p3 IS 'The third mlid in the materialized path. See p1.';


--
-- Name: COLUMN drupal_menu_tree.p4; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p4 IS 'The fourth mlid in the materialized path. See p1.';


--
-- Name: COLUMN drupal_menu_tree.p5; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p5 IS 'The fifth mlid in the materialized path. See p1.';


--
-- Name: COLUMN drupal_menu_tree.p6; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p6 IS 'The sixth mlid in the materialized path. See p1.';


--
-- Name: COLUMN drupal_menu_tree.p7; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p7 IS 'The seventh mlid in the materialized path. See p1.';


--
-- Name: COLUMN drupal_menu_tree.p8; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p8 IS 'The eighth mlid in the materialized path. See p1.';


--
-- Name: COLUMN drupal_menu_tree.p9; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.p9 IS 'The ninth mlid in the materialized path. See p1.';


--
-- Name: COLUMN drupal_menu_tree.form_class; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_menu_tree.form_class IS 'meh';


--
-- Name: drupal_menu_tree_mlid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_menu_tree_mlid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_menu_tree_mlid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_menu_tree_mlid_seq OWNED BY public.drupal_menu_tree.mlid;


--
-- Name: drupal_node; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node (
    nid integer NOT NULL,
    vid bigint,
    type character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT drupal_node_nid_check CHECK ((nid >= 0)),
    CONSTRAINT drupal_node_vid_check CHECK ((vid >= 0))
);


--
-- Name: TABLE drupal_node; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node IS 'The base table for node entities.';


--
-- Name: COLUMN drupal_node.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node.type IS 'The ID of the target entity.';


--
-- Name: drupal_node__body; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node__body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    body_value text NOT NULL,
    body_summary text,
    body_format character varying(255),
    CONSTRAINT drupal_node__body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node__body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node__body_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node__body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node__body IS 'Data storage for node field body.';


--
-- Name: COLUMN drupal_node__body.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node__body.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node__body.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__body.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node__body.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__body.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node__body.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__body.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node__body.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: drupal_node__comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node__comment (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    comment_status integer DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_node__comment_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node__comment_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node__comment_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node__comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node__comment IS 'Data storage for node field comment.';


--
-- Name: COLUMN drupal_node__comment.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__comment.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node__comment.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__comment.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node__comment.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__comment.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node__comment.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__comment.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node__comment.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__comment.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node__comment.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__comment.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_node__comment.comment_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__comment.comment_status IS 'Whether comments are allowed on this entity: 0 = no, 1 = closed (read only), 2 = open (read/write).';


--
-- Name: drupal_node__field_h5p; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node__field_h5p (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_h5p_h5p_content_id bigint,
    CONSTRAINT drupal_node__field_h5p_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node__field_h5p_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node__field_h5p_field_h5p_h5p_content_id_check CHECK ((field_h5p_h5p_content_id >= 0)),
    CONSTRAINT drupal_node__field_h5p_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node__field_h5p; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node__field_h5p IS 'Data storage for node field field_h5p.';


--
-- Name: COLUMN drupal_node__field_h5p.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_h5p.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node__field_h5p.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_h5p.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node__field_h5p.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_h5p.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node__field_h5p.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_h5p.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node__field_h5p.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_h5p.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node__field_h5p.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_h5p.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_node__field_h5p.field_h5p_h5p_content_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_h5p.field_h5p_h5p_content_id IS 'Referance to the H5P Content entity ID';


--
-- Name: drupal_node__field_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node__field_image (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_image_target_id bigint NOT NULL,
    field_image_alt character varying(512),
    field_image_title character varying(1024),
    field_image_width bigint,
    field_image_height bigint,
    CONSTRAINT drupal_node__field_image_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node__field_image_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node__field_image_field_image_height_check CHECK ((field_image_height >= 0)),
    CONSTRAINT drupal_node__field_image_field_image_target_id_check CHECK ((field_image_target_id >= 0)),
    CONSTRAINT drupal_node__field_image_field_image_width_check CHECK ((field_image_width >= 0)),
    CONSTRAINT drupal_node__field_image_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node__field_image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node__field_image IS 'Data storage for node field field_image.';


--
-- Name: COLUMN drupal_node__field_image.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node__field_image.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node__field_image.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node__field_image.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node__field_image.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node__field_image.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_node__field_image.field_image_target_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.field_image_target_id IS 'The ID of the file entity.';


--
-- Name: COLUMN drupal_node__field_image.field_image_alt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.field_image_alt IS 'Alternative image text, for the image''s ''alt'' attribute.';


--
-- Name: COLUMN drupal_node__field_image.field_image_title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.field_image_title IS 'Image title text, for the image''s ''title'' attribute.';


--
-- Name: COLUMN drupal_node__field_image.field_image_width; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.field_image_width IS 'The width of the image in pixels.';


--
-- Name: COLUMN drupal_node__field_image.field_image_height; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_image.field_image_height IS 'The height of the image in pixels.';


--
-- Name: drupal_node__field_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node__field_tags (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_tags_target_id bigint NOT NULL,
    CONSTRAINT drupal_node__field_tags_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node__field_tags_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node__field_tags_field_tags_target_id_check CHECK ((field_tags_target_id >= 0)),
    CONSTRAINT drupal_node__field_tags_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node__field_tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node__field_tags IS 'Data storage for node field field_tags.';


--
-- Name: COLUMN drupal_node__field_tags.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_tags.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node__field_tags.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_tags.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node__field_tags.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_tags.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node__field_tags.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_tags.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node__field_tags.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_tags.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node__field_tags.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_tags.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_node__field_tags.field_tags_target_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node__field_tags.field_tags_target_id IS 'The ID of the target entity.';


--
-- Name: drupal_node_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_access (
    nid bigint DEFAULT 0 NOT NULL,
    langcode character varying(12) DEFAULT ''::character varying NOT NULL,
    fallback integer DEFAULT 1 NOT NULL,
    gid bigint DEFAULT 0 NOT NULL,
    realm character varying(255) DEFAULT ''::character varying NOT NULL,
    grant_view integer DEFAULT 0 NOT NULL,
    grant_update integer DEFAULT 0 NOT NULL,
    grant_delete integer DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_node_access_fallback_check CHECK ((fallback >= 0)),
    CONSTRAINT drupal_node_access_gid_check CHECK ((gid >= 0)),
    CONSTRAINT drupal_node_access_grant_delete_check CHECK ((grant_delete >= 0)),
    CONSTRAINT drupal_node_access_grant_update_check CHECK ((grant_update >= 0)),
    CONSTRAINT drupal_node_access_grant_view_check CHECK ((grant_view >= 0)),
    CONSTRAINT drupal_node_access_nid_check CHECK ((nid >= 0))
);


--
-- Name: TABLE drupal_node_access; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_access IS 'Identifies which realm/grant pairs a user must possess in order to view, update, or delete specific nodes.';


--
-- Name: COLUMN drupal_node_access.nid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_access.nid IS 'The drupal_node.nid this record affects.';


--
-- Name: COLUMN drupal_node_access.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_access.langcode IS 'The drupal_language.langcode of this node.';


--
-- Name: COLUMN drupal_node_access.fallback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_access.fallback IS 'Boolean indicating whether this record should be used as a fallback if a language condition is not provided.';


--
-- Name: COLUMN drupal_node_access.gid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_access.gid IS 'The grant ID a user must possess in the specified realm to gain this row''s privileges on the node.';


--
-- Name: COLUMN drupal_node_access.realm; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_access.realm IS 'The realm in which the user must possess the grant ID. Modules can define one or more realms by implementing hook_node_grants().';


--
-- Name: COLUMN drupal_node_access.grant_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_access.grant_view IS 'Boolean indicating whether a user with the realm/grant pair can view this node.';


--
-- Name: COLUMN drupal_node_access.grant_update; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_access.grant_update IS 'Boolean indicating whether a user with the realm/grant pair can edit this node.';


--
-- Name: COLUMN drupal_node_access.grant_delete; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_access.grant_delete IS 'Boolean indicating whether a user with the realm/grant pair can delete this node.';


--
-- Name: drupal_node_field_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_field_data (
    nid bigint NOT NULL,
    vid bigint NOT NULL,
    type character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    uid bigint NOT NULL,
    title character varying(255) NOT NULL,
    created integer NOT NULL,
    changed integer NOT NULL,
    promote smallint NOT NULL,
    sticky smallint NOT NULL,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT drupal_node_field_data_nid_check CHECK ((nid >= 0)),
    CONSTRAINT drupal_node_field_data_uid_check CHECK ((uid >= 0)),
    CONSTRAINT drupal_node_field_data_vid_check CHECK ((vid >= 0))
);


--
-- Name: TABLE drupal_node_field_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_field_data IS 'The data table for node entities.';


--
-- Name: COLUMN drupal_node_field_data.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_field_data.type IS 'The ID of the target entity.';


--
-- Name: COLUMN drupal_node_field_data.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_field_data.uid IS 'The ID of the target entity.';


--
-- Name: drupal_node_field_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_field_revision (
    nid bigint NOT NULL,
    vid bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    uid bigint NOT NULL,
    title character varying(255),
    created integer,
    changed integer,
    promote smallint,
    sticky smallint,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT drupal_node_field_revision_nid_check CHECK ((nid >= 0)),
    CONSTRAINT drupal_node_field_revision_uid_check CHECK ((uid >= 0)),
    CONSTRAINT drupal_node_field_revision_vid_check CHECK ((vid >= 0))
);


--
-- Name: TABLE drupal_node_field_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_field_revision IS 'The revision data table for node entities.';


--
-- Name: COLUMN drupal_node_field_revision.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_field_revision.uid IS 'The ID of the target entity.';


--
-- Name: drupal_node_nid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_node_nid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_node_nid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_node_nid_seq OWNED BY public.drupal_node.nid;


--
-- Name: drupal_node_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_revision (
    nid bigint NOT NULL,
    vid integer NOT NULL,
    langcode character varying(12) NOT NULL,
    revision_uid bigint,
    revision_timestamp integer,
    revision_log text,
    revision_default smallint,
    CONSTRAINT drupal_node_revision_nid_check CHECK ((nid >= 0)),
    CONSTRAINT drupal_node_revision_revision_uid_check CHECK ((revision_uid >= 0)),
    CONSTRAINT drupal_node_revision_vid_check CHECK ((vid >= 0))
);


--
-- Name: TABLE drupal_node_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_revision IS 'The revision table for node entities.';


--
-- Name: COLUMN drupal_node_revision.revision_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision.revision_uid IS 'The ID of the target entity.';


--
-- Name: drupal_node_revision__body; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_revision__body (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    body_value text NOT NULL,
    body_summary text,
    body_format character varying(255),
    CONSTRAINT drupal_node_revision__body_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node_revision__body_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node_revision__body_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node_revision__body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_revision__body IS 'Revision archive storage for node field body.';


--
-- Name: COLUMN drupal_node_revision__body.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__body.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node_revision__body.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__body.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node_revision__body.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__body.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__body.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__body.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__body.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__body.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node_revision__body.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__body.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: drupal_node_revision__comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_revision__comment (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    comment_status integer DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_node_revision__comment_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node_revision__comment_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node_revision__comment_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node_revision__comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_revision__comment IS 'Revision archive storage for node field comment.';


--
-- Name: COLUMN drupal_node_revision__comment.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__comment.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node_revision__comment.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__comment.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node_revision__comment.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__comment.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__comment.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__comment.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__comment.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__comment.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node_revision__comment.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__comment.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_node_revision__comment.comment_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__comment.comment_status IS 'Whether comments are allowed on this entity: 0 = no, 1 = closed (read only), 2 = open (read/write).';


--
-- Name: drupal_node_revision__field_h5p; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_revision__field_h5p (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_h5p_h5p_content_id bigint,
    CONSTRAINT drupal_node_revision__field_h5p_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node_revision__field_h5p_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node_revision__field_h5p_field_h5p_h5p_content_id_check CHECK ((field_h5p_h5p_content_id >= 0)),
    CONSTRAINT drupal_node_revision__field_h5p_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node_revision__field_h5p; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_revision__field_h5p IS 'Revision archive storage for node field field_h5p.';


--
-- Name: COLUMN drupal_node_revision__field_h5p.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_h5p.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node_revision__field_h5p.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_h5p.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node_revision__field_h5p.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_h5p.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__field_h5p.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_h5p.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__field_h5p.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_h5p.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node_revision__field_h5p.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_h5p.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_node_revision__field_h5p.field_h5p_h5p_content_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_h5p.field_h5p_h5p_content_id IS 'Referance to the H5P Content entity ID';


--
-- Name: drupal_node_revision__field_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_revision__field_image (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_image_target_id bigint NOT NULL,
    field_image_alt character varying(512),
    field_image_title character varying(1024),
    field_image_width bigint,
    field_image_height bigint,
    CONSTRAINT drupal_node_revision__field_image_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node_revision__field_image_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node_revision__field_image_field_image_height_check CHECK ((field_image_height >= 0)),
    CONSTRAINT drupal_node_revision__field_image_field_image_target_id_check CHECK ((field_image_target_id >= 0)),
    CONSTRAINT drupal_node_revision__field_image_field_image_width_check CHECK ((field_image_width >= 0)),
    CONSTRAINT drupal_node_revision__field_image_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node_revision__field_image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_revision__field_image IS 'Revision archive storage for node field field_image.';


--
-- Name: COLUMN drupal_node_revision__field_image.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node_revision__field_image.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node_revision__field_image.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__field_image.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__field_image.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node_revision__field_image.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_node_revision__field_image.field_image_target_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.field_image_target_id IS 'The ID of the file entity.';


--
-- Name: COLUMN drupal_node_revision__field_image.field_image_alt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.field_image_alt IS 'Alternative image text, for the image''s ''alt'' attribute.';


--
-- Name: COLUMN drupal_node_revision__field_image.field_image_title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.field_image_title IS 'Image title text, for the image''s ''title'' attribute.';


--
-- Name: COLUMN drupal_node_revision__field_image.field_image_width; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.field_image_width IS 'The width of the image in pixels.';


--
-- Name: COLUMN drupal_node_revision__field_image.field_image_height; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_image.field_image_height IS 'The height of the image in pixels.';


--
-- Name: drupal_node_revision__field_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_node_revision__field_tags (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    field_tags_target_id bigint NOT NULL,
    CONSTRAINT drupal_node_revision__field_tags_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_node_revision__field_tags_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_node_revision__field_tags_field_tags_target_id_check CHECK ((field_tags_target_id >= 0)),
    CONSTRAINT drupal_node_revision__field_tags_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_node_revision__field_tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_node_revision__field_tags IS 'Revision archive storage for node field field_tags.';


--
-- Name: COLUMN drupal_node_revision__field_tags.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_tags.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_node_revision__field_tags.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_tags.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_node_revision__field_tags.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_tags.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__field_tags.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_tags.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_node_revision__field_tags.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_tags.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_node_revision__field_tags.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_tags.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_node_revision__field_tags.field_tags_target_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_node_revision__field_tags.field_tags_target_id IS 'The ID of the target entity.';


--
-- Name: drupal_node_revision_vid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_node_revision_vid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_node_revision_vid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_node_revision_vid_seq OWNED BY public.drupal_node_revision.vid;


--
-- Name: drupal_path_alias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_path_alias (
    id integer NOT NULL,
    revision_id bigint,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    path character varying(255),
    alias character varying(255),
    status smallint NOT NULL,
    CONSTRAINT drupal_path_alias_id_check CHECK ((id >= 0)),
    CONSTRAINT drupal_path_alias_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_path_alias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_path_alias IS 'The base table for path_alias entities.';


--
-- Name: drupal_path_alias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_path_alias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_path_alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_path_alias_id_seq OWNED BY public.drupal_path_alias.id;


--
-- Name: drupal_path_alias_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_path_alias_revision (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    langcode character varying(12) NOT NULL,
    path character varying(255),
    alias character varying(255),
    status smallint NOT NULL,
    revision_default smallint,
    CONSTRAINT drupal_path_alias_revision_id_check1 CHECK ((id >= 0)),
    CONSTRAINT drupal_path_alias_revision_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_path_alias_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_path_alias_revision IS 'The revision table for path_alias entities.';


--
-- Name: drupal_path_alias_revision_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_path_alias_revision_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_path_alias_revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_path_alias_revision_revision_id_seq OWNED BY public.drupal_path_alias_revision.revision_id;


--
-- Name: drupal_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_queue (
    item_id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    data bytea,
    expire integer DEFAULT 0 NOT NULL,
    created integer DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_queue_item_id_check CHECK ((item_id >= 0))
);


--
-- Name: TABLE drupal_queue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_queue IS 'Stores items in queues.';


--
-- Name: COLUMN drupal_queue.item_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_queue.item_id IS 'Primary Key: Unique item ID.';


--
-- Name: COLUMN drupal_queue.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_queue.name IS 'The queue name.';


--
-- Name: COLUMN drupal_queue.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_queue.data IS 'The arbitrary data for the item.';


--
-- Name: COLUMN drupal_queue.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_queue.expire IS 'Timestamp when the claim lease expires on the item.';


--
-- Name: COLUMN drupal_queue.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_queue.created IS 'Timestamp when the item was created.';


--
-- Name: drupal_queue_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_queue_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_queue_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_queue_item_id_seq OWNED BY public.drupal_queue.item_id;


--
-- Name: drupal_router; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_router (
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    pattern_outline character varying(255) DEFAULT ''::character varying NOT NULL,
    fit integer DEFAULT 0 NOT NULL,
    route bytea,
    number_parts smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE drupal_router; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_router IS 'Maps paths to various callbacks (access, page and title)';


--
-- Name: COLUMN drupal_router.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_router.name IS 'Primary Key: Machine name of this route';


--
-- Name: COLUMN drupal_router.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_router.path IS 'The path for this URI';


--
-- Name: COLUMN drupal_router.pattern_outline; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_router.pattern_outline IS 'The pattern';


--
-- Name: COLUMN drupal_router.fit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_router.fit IS 'A numeric representation of how specific the path is.';


--
-- Name: COLUMN drupal_router.route; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_router.route IS 'A serialized Route object';


--
-- Name: COLUMN drupal_router.number_parts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_router.number_parts IS 'Number of parts in this router path.';


--
-- Name: drupal_s3fs_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_s3fs_file (
    uri character varying(255) DEFAULT ''::character varying NOT NULL,
    filesize bigint DEFAULT 0 NOT NULL,
    "timestamp" bigint DEFAULT 0 NOT NULL,
    dir integer DEFAULT 0 NOT NULL,
    version character varying(32) DEFAULT ''::character varying,
    CONSTRAINT drupal_s3fs_file_filesize_check CHECK ((filesize >= 0)),
    CONSTRAINT drupal_s3fs_file_timestamp_check CHECK (("timestamp" >= 0))
);


--
-- Name: TABLE drupal_s3fs_file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_s3fs_file IS 'Stores metadata about files in S3.';


--
-- Name: COLUMN drupal_s3fs_file.uri; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_s3fs_file.uri IS 'The S3 URI of the file.';


--
-- Name: COLUMN drupal_s3fs_file.filesize; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_s3fs_file.filesize IS 'The size of the file in bytes.';


--
-- Name: COLUMN drupal_s3fs_file."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_s3fs_file."timestamp" IS 'UNIX timestamp for when the file was added.';


--
-- Name: COLUMN drupal_s3fs_file.dir; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_s3fs_file.dir IS 'Boolean indicating whether or not this object is a directory.';


--
-- Name: COLUMN drupal_s3fs_file.version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_s3fs_file.version IS 'The S3 VersionId of the object.';


--
-- Name: drupal_search_dataset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_search_dataset (
    sid bigint DEFAULT 0 NOT NULL,
    langcode character varying(12) DEFAULT ''::character varying NOT NULL,
    type character varying(64) NOT NULL,
    data text NOT NULL,
    reindex bigint DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_search_dataset_reindex_check CHECK ((reindex >= 0)),
    CONSTRAINT drupal_search_dataset_sid_check CHECK ((sid >= 0))
);


--
-- Name: TABLE drupal_search_dataset; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_search_dataset IS 'Stores items that will be searched.';


--
-- Name: COLUMN drupal_search_dataset.sid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_dataset.sid IS 'Search item ID, e.g. node ID for nodes.';


--
-- Name: COLUMN drupal_search_dataset.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_dataset.langcode IS 'The drupal_languages.langcode of the item variant.';


--
-- Name: COLUMN drupal_search_dataset.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_dataset.type IS 'Type of item, e.g. node.';


--
-- Name: COLUMN drupal_search_dataset.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_dataset.data IS 'List of space-separated words from the item.';


--
-- Name: COLUMN drupal_search_dataset.reindex; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_dataset.reindex IS 'Set to force node reindexing.';


--
-- Name: drupal_search_index; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_search_index (
    word character varying(50) DEFAULT ''::character varying NOT NULL,
    sid bigint DEFAULT 0 NOT NULL,
    langcode character varying(12) DEFAULT ''::character varying NOT NULL,
    type character varying(64) NOT NULL,
    score real,
    CONSTRAINT drupal_search_index_sid_check CHECK ((sid >= 0))
);


--
-- Name: TABLE drupal_search_index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_search_index IS 'Stores the search index, associating words, items and scores.';


--
-- Name: COLUMN drupal_search_index.word; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_index.word IS 'The drupal_search_total.word that is associated with the search item.';


--
-- Name: COLUMN drupal_search_index.sid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_index.sid IS 'The drupal_search_dataset.sid of the searchable item to which the word belongs.';


--
-- Name: COLUMN drupal_search_index.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_index.langcode IS 'The drupal_languages.langcode of the item variant.';


--
-- Name: COLUMN drupal_search_index.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_index.type IS 'The drupal_search_dataset.type of the searchable item to which the word belongs.';


--
-- Name: COLUMN drupal_search_index.score; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_index.score IS 'The numeric score of the word, higher being more important.';


--
-- Name: drupal_search_total; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_search_total (
    word character varying(50) DEFAULT ''::character varying NOT NULL,
    count real
);


--
-- Name: TABLE drupal_search_total; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_search_total IS 'Stores search totals for words.';


--
-- Name: COLUMN drupal_search_total.word; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_total.word IS 'Primary Key: Unique word in the search index.';


--
-- Name: COLUMN drupal_search_total.count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_search_total.count IS 'The count of the word in the index using Zipf''s law to equalize the probability distribution.';


--
-- Name: drupal_semaphore; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_semaphore (
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value character varying(255) DEFAULT ''::character varying NOT NULL,
    expire double precision NOT NULL
);


--
-- Name: TABLE drupal_semaphore; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_semaphore IS 'Table for holding semaphores, locks, flags, etc. that cannot be stored as state since they must not be cached.';


--
-- Name: COLUMN drupal_semaphore.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_semaphore.name IS 'Primary Key: Unique name.';


--
-- Name: COLUMN drupal_semaphore.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_semaphore.value IS 'A value for the semaphore.';


--
-- Name: COLUMN drupal_semaphore.expire; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_semaphore.expire IS 'A Unix timestamp with microseconds indicating when the semaphore should expire.';


--
-- Name: drupal_sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_sequences (
    value integer NOT NULL,
    CONSTRAINT drupal_sequences_value_check CHECK ((value >= 0))
);


--
-- Name: TABLE drupal_sequences; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_sequences IS 'Stores IDs.';


--
-- Name: COLUMN drupal_sequences.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_sequences.value IS 'The value of the sequence.';


--
-- Name: drupal_sequences_value_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_sequences_value_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_sequences_value_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_sequences_value_seq OWNED BY public.drupal_sequences.value;


--
-- Name: drupal_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_sessions (
    uid bigint NOT NULL,
    sid character varying(128) NOT NULL,
    hostname character varying(128) DEFAULT ''::character varying NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    session bytea,
    CONSTRAINT drupal_sessions_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_sessions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_sessions IS 'Drupal''s session handlers read and write into the sessions table. Each record represents a user session, either anonymous or authenticated.';


--
-- Name: COLUMN drupal_sessions.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_sessions.uid IS 'The drupal_users.uid corresponding to a session, or 0 for anonymous user.';


--
-- Name: COLUMN drupal_sessions.sid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_sessions.sid IS 'A session ID (hashed). The value is generated by Drupal''s session handlers.';


--
-- Name: COLUMN drupal_sessions.hostname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_sessions.hostname IS 'The IP address that last used this session ID (sid).';


--
-- Name: COLUMN drupal_sessions."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_sessions."timestamp" IS 'The Unix timestamp when this session last requested a page. Old records are purged by PHP automatically.';


--
-- Name: COLUMN drupal_sessions.session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_sessions.session IS 'The serialized contents of $_SESSION, an array of name/value pairs that persists across page requests by this session ID. Drupal loads $_SESSION from here at the start of each request and saves it at the end.';


--
-- Name: drupal_shortcut; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_shortcut (
    id integer NOT NULL,
    shortcut_set character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT drupal_shortcut_id_check CHECK ((id >= 0))
);


--
-- Name: TABLE drupal_shortcut; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_shortcut IS 'The base table for shortcut entities.';


--
-- Name: COLUMN drupal_shortcut.shortcut_set; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_shortcut.shortcut_set IS 'The ID of the target entity.';


--
-- Name: drupal_shortcut_field_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_shortcut_field_data (
    id bigint NOT NULL,
    shortcut_set character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    title character varying(255),
    weight integer,
    link__uri character varying(2048),
    link__title character varying(255),
    link__options bytea,
    default_langcode smallint NOT NULL,
    CONSTRAINT drupal_shortcut_field_data_id_check CHECK ((id >= 0))
);


--
-- Name: TABLE drupal_shortcut_field_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_shortcut_field_data IS 'The data table for shortcut entities.';


--
-- Name: COLUMN drupal_shortcut_field_data.shortcut_set; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_shortcut_field_data.shortcut_set IS 'The ID of the target entity.';


--
-- Name: COLUMN drupal_shortcut_field_data.link__uri; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_shortcut_field_data.link__uri IS 'The URI of the link.';


--
-- Name: COLUMN drupal_shortcut_field_data.link__title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_shortcut_field_data.link__title IS 'The link text.';


--
-- Name: COLUMN drupal_shortcut_field_data.link__options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_shortcut_field_data.link__options IS 'Serialized array of options for the link.';


--
-- Name: drupal_shortcut_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_shortcut_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_shortcut_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_shortcut_id_seq OWNED BY public.drupal_shortcut.id;


--
-- Name: drupal_shortcut_set_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_shortcut_set_users (
    uid bigint DEFAULT 0 NOT NULL,
    set_name character varying(32) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT drupal_shortcut_set_users_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_shortcut_set_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_shortcut_set_users IS 'Maps users to shortcut sets.';


--
-- Name: COLUMN drupal_shortcut_set_users.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_shortcut_set_users.uid IS 'The drupal_users.uid for this set.';


--
-- Name: COLUMN drupal_shortcut_set_users.set_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_shortcut_set_users.set_name IS 'The drupal_shortcut_set.set_name that will be displayed for this user.';


--
-- Name: drupal_taxonomy_index; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_taxonomy_index (
    nid bigint DEFAULT 0 NOT NULL,
    tid bigint DEFAULT 0 NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    sticky smallint DEFAULT 0,
    created integer DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_taxonomy_index_nid_check CHECK ((nid >= 0)),
    CONSTRAINT drupal_taxonomy_index_tid_check CHECK ((tid >= 0))
);


--
-- Name: TABLE drupal_taxonomy_index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_taxonomy_index IS 'Maintains denormalized information about node/term relationships.';


--
-- Name: COLUMN drupal_taxonomy_index.nid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_index.nid IS 'The drupal_node.nid this record tracks.';


--
-- Name: COLUMN drupal_taxonomy_index.tid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_index.tid IS 'The term ID.';


--
-- Name: COLUMN drupal_taxonomy_index.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_index.status IS 'Boolean indicating whether the node is published (visible to non-administrators).';


--
-- Name: COLUMN drupal_taxonomy_index.sticky; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_index.sticky IS 'Boolean indicating whether the node is sticky.';


--
-- Name: COLUMN drupal_taxonomy_index.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_index.created IS 'The Unix timestamp when the node was created.';


--
-- Name: drupal_taxonomy_term__parent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_taxonomy_term__parent (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    parent_target_id bigint NOT NULL,
    CONSTRAINT drupal_taxonomy_term__parent_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_taxonomy_term__parent_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_taxonomy_term__parent_parent_target_id_check CHECK ((parent_target_id >= 0)),
    CONSTRAINT drupal_taxonomy_term__parent_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_taxonomy_term__parent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_taxonomy_term__parent IS 'Data storage for taxonomy_term field parent.';


--
-- Name: COLUMN drupal_taxonomy_term__parent.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term__parent.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_taxonomy_term__parent.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term__parent.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_taxonomy_term__parent.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term__parent.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_taxonomy_term__parent.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term__parent.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_taxonomy_term__parent.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term__parent.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_taxonomy_term__parent.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term__parent.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_taxonomy_term__parent.parent_target_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term__parent.parent_target_id IS 'The ID of the target entity.';


--
-- Name: drupal_taxonomy_term_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_taxonomy_term_data (
    tid integer NOT NULL,
    revision_id bigint,
    vid character varying(32) NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT drupal_taxonomy_term_data_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT drupal_taxonomy_term_data_tid_check CHECK ((tid >= 0))
);


--
-- Name: TABLE drupal_taxonomy_term_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_taxonomy_term_data IS 'The base table for taxonomy_term entities.';


--
-- Name: COLUMN drupal_taxonomy_term_data.vid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_data.vid IS 'The ID of the target entity.';


--
-- Name: drupal_taxonomy_term_data_tid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_taxonomy_term_data_tid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_taxonomy_term_data_tid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_taxonomy_term_data_tid_seq OWNED BY public.drupal_taxonomy_term_data.tid;


--
-- Name: drupal_taxonomy_term_field_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_taxonomy_term_field_data (
    tid bigint NOT NULL,
    revision_id bigint NOT NULL,
    vid character varying(32) NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    name character varying(255) NOT NULL,
    description__value text,
    description__format character varying(255),
    weight integer NOT NULL,
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT drupal_taxonomy_term_field_data_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT drupal_taxonomy_term_field_data_tid_check CHECK ((tid >= 0))
);


--
-- Name: TABLE drupal_taxonomy_term_field_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_taxonomy_term_field_data IS 'The data table for taxonomy_term entities.';


--
-- Name: COLUMN drupal_taxonomy_term_field_data.vid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_field_data.vid IS 'The ID of the target entity.';


--
-- Name: drupal_taxonomy_term_field_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_taxonomy_term_field_revision (
    tid bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    status smallint NOT NULL,
    name character varying(255),
    description__value text,
    description__format character varying(255),
    changed integer,
    default_langcode smallint NOT NULL,
    revision_translation_affected smallint,
    CONSTRAINT drupal_taxonomy_term_field_revision_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT drupal_taxonomy_term_field_revision_tid_check CHECK ((tid >= 0))
);


--
-- Name: TABLE drupal_taxonomy_term_field_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_taxonomy_term_field_revision IS 'The revision data table for taxonomy_term entities.';


--
-- Name: drupal_taxonomy_term_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_taxonomy_term_revision (
    tid bigint NOT NULL,
    revision_id integer NOT NULL,
    langcode character varying(12) NOT NULL,
    revision_user bigint,
    revision_created integer,
    revision_log_message text,
    revision_default smallint,
    CONSTRAINT drupal_taxonomy_term_revision_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT drupal_taxonomy_term_revision_revision_user_check CHECK ((revision_user >= 0)),
    CONSTRAINT drupal_taxonomy_term_revision_tid_check CHECK ((tid >= 0))
);


--
-- Name: TABLE drupal_taxonomy_term_revision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_taxonomy_term_revision IS 'The revision table for taxonomy_term entities.';


--
-- Name: COLUMN drupal_taxonomy_term_revision.revision_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_revision.revision_user IS 'The ID of the target entity.';


--
-- Name: drupal_taxonomy_term_revision__parent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_taxonomy_term_revision__parent (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    parent_target_id bigint NOT NULL,
    CONSTRAINT drupal_taxonomy_term_revision__parent_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_taxonomy_term_revision__parent_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_taxonomy_term_revision__parent_parent_target_id_check CHECK ((parent_target_id >= 0)),
    CONSTRAINT drupal_taxonomy_term_revision__parent_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_taxonomy_term_revision__parent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_taxonomy_term_revision__parent IS 'Revision archive storage for taxonomy_term field parent.';


--
-- Name: COLUMN drupal_taxonomy_term_revision__parent.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_revision__parent.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_taxonomy_term_revision__parent.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_revision__parent.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_taxonomy_term_revision__parent.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_revision__parent.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_taxonomy_term_revision__parent.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_revision__parent.revision_id IS 'The entity revision id this data is attached to';


--
-- Name: COLUMN drupal_taxonomy_term_revision__parent.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_revision__parent.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_taxonomy_term_revision__parent.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_revision__parent.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_taxonomy_term_revision__parent.parent_target_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_taxonomy_term_revision__parent.parent_target_id IS 'The ID of the target entity.';


--
-- Name: drupal_taxonomy_term_revision_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_taxonomy_term_revision_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_taxonomy_term_revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_taxonomy_term_revision_revision_id_seq OWNED BY public.drupal_taxonomy_term_revision.revision_id;


--
-- Name: drupal_user__roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_user__roles (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    roles_target_id character varying(255) NOT NULL,
    CONSTRAINT drupal_user__roles_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_user__roles_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_user__roles_revision_id_check CHECK ((revision_id >= 0))
);


--
-- Name: TABLE drupal_user__roles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_user__roles IS 'Data storage for user field roles.';


--
-- Name: COLUMN drupal_user__roles.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__roles.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_user__roles.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__roles.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_user__roles.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__roles.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_user__roles.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__roles.revision_id IS 'The entity revision id this data is attached to, which for an unversioned entity type is the same as the entity id';


--
-- Name: COLUMN drupal_user__roles.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__roles.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_user__roles.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__roles.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_user__roles.roles_target_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__roles.roles_target_id IS 'The ID of the target entity.';


--
-- Name: drupal_user__user_picture; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_user__user_picture (
    bundle character varying(128) DEFAULT ''::character varying NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    entity_id bigint NOT NULL,
    revision_id bigint NOT NULL,
    langcode character varying(32) DEFAULT ''::character varying NOT NULL,
    delta bigint NOT NULL,
    user_picture_target_id bigint NOT NULL,
    user_picture_alt character varying(512),
    user_picture_title character varying(1024),
    user_picture_width bigint,
    user_picture_height bigint,
    CONSTRAINT drupal_user__user_picture_delta_check CHECK ((delta >= 0)),
    CONSTRAINT drupal_user__user_picture_entity_id_check CHECK ((entity_id >= 0)),
    CONSTRAINT drupal_user__user_picture_revision_id_check CHECK ((revision_id >= 0)),
    CONSTRAINT drupal_user__user_picture_user_picture_height_check CHECK ((user_picture_height >= 0)),
    CONSTRAINT drupal_user__user_picture_user_picture_target_id_check CHECK ((user_picture_target_id >= 0)),
    CONSTRAINT drupal_user__user_picture_user_picture_width_check CHECK ((user_picture_width >= 0))
);


--
-- Name: TABLE drupal_user__user_picture; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_user__user_picture IS 'Data storage for user field user_picture.';


--
-- Name: COLUMN drupal_user__user_picture.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.bundle IS 'The field instance bundle to which this row belongs, used when deleting a field instance';


--
-- Name: COLUMN drupal_user__user_picture.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.deleted IS 'A boolean indicating whether this data item has been deleted';


--
-- Name: COLUMN drupal_user__user_picture.entity_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.entity_id IS 'The entity id this data is attached to';


--
-- Name: COLUMN drupal_user__user_picture.revision_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.revision_id IS 'The entity revision id this data is attached to, which for an unversioned entity type is the same as the entity id';


--
-- Name: COLUMN drupal_user__user_picture.langcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.langcode IS 'The language code for this data item.';


--
-- Name: COLUMN drupal_user__user_picture.delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.delta IS 'The sequence number for this data item, used for multi-value fields';


--
-- Name: COLUMN drupal_user__user_picture.user_picture_target_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.user_picture_target_id IS 'The ID of the file entity.';


--
-- Name: COLUMN drupal_user__user_picture.user_picture_alt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.user_picture_alt IS 'Alternative image text, for the image''s ''alt'' attribute.';


--
-- Name: COLUMN drupal_user__user_picture.user_picture_title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.user_picture_title IS 'Image title text, for the image''s ''title'' attribute.';


--
-- Name: COLUMN drupal_user__user_picture.user_picture_width; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.user_picture_width IS 'The width of the image in pixels.';


--
-- Name: COLUMN drupal_user__user_picture.user_picture_height; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_user__user_picture.user_picture_height IS 'The height of the image in pixels.';


--
-- Name: drupal_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_users (
    uid bigint NOT NULL,
    uuid character varying(128) NOT NULL,
    langcode character varying(12) NOT NULL,
    CONSTRAINT drupal_users_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_users IS 'The base table for user entities.';


--
-- Name: drupal_users_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_users_data (
    uid bigint DEFAULT 0 NOT NULL,
    module character varying(50) DEFAULT ''::character varying NOT NULL,
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    value bytea,
    serialized integer DEFAULT 0,
    CONSTRAINT drupal_users_data_serialized_check CHECK ((serialized >= 0)),
    CONSTRAINT drupal_users_data_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_users_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_users_data IS 'Stores module data as key/value pairs per user.';


--
-- Name: COLUMN drupal_users_data.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_users_data.uid IS 'The drupal_users.uid this record affects.';


--
-- Name: COLUMN drupal_users_data.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_users_data.module IS 'The name of the module declaring the variable.';


--
-- Name: COLUMN drupal_users_data.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_users_data.name IS 'The identifier of the data.';


--
-- Name: COLUMN drupal_users_data.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_users_data.value IS 'The value.';


--
-- Name: COLUMN drupal_users_data.serialized; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_users_data.serialized IS 'Whether value is serialized.';


--
-- Name: drupal_users_field_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_users_field_data (
    uid bigint NOT NULL,
    langcode character varying(12) NOT NULL,
    preferred_langcode character varying(12),
    preferred_admin_langcode character varying(12),
    name character varying(60) NOT NULL,
    pass character varying(255),
    mail character varying(254),
    timezone character varying(32),
    status smallint,
    created integer NOT NULL,
    changed integer,
    access integer NOT NULL,
    login integer,
    init character varying(254),
    default_langcode smallint NOT NULL,
    CONSTRAINT drupal_users_field_data_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_users_field_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_users_field_data IS 'The data table for user entities.';


--
-- Name: drupal_watchdog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drupal_watchdog (
    wid integer NOT NULL,
    uid bigint DEFAULT 0 NOT NULL,
    type character varying(64) DEFAULT ''::character varying NOT NULL,
    message text NOT NULL,
    variables bytea NOT NULL,
    severity integer DEFAULT 0 NOT NULL,
    link text,
    location text NOT NULL,
    referer text,
    hostname character varying(128) DEFAULT ''::character varying NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    CONSTRAINT drupal_watchdog_severity_check CHECK ((severity >= 0)),
    CONSTRAINT drupal_watchdog_uid_check CHECK ((uid >= 0))
);


--
-- Name: TABLE drupal_watchdog; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.drupal_watchdog IS 'Table that contains logs of all system events.';


--
-- Name: COLUMN drupal_watchdog.wid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.wid IS 'Primary Key: Unique watchdog event ID.';


--
-- Name: COLUMN drupal_watchdog.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.uid IS 'The drupal_users.uid of the user who triggered the event.';


--
-- Name: COLUMN drupal_watchdog.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.type IS 'Type of log message, for example "user" or "page not found."';


--
-- Name: COLUMN drupal_watchdog.message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.message IS 'Text of log message to be passed into the t() function.';


--
-- Name: COLUMN drupal_watchdog.variables; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.variables IS 'Serialized array of variables that match the message string and that is passed into the t() function.';


--
-- Name: COLUMN drupal_watchdog.severity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.severity IS 'The severity level of the event. ranges from 0 (Emergency) to 7 (Debug)';


--
-- Name: COLUMN drupal_watchdog.link; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.link IS 'Link to view the result of the event.';


--
-- Name: COLUMN drupal_watchdog.location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.location IS 'URL of the origin of the event.';


--
-- Name: COLUMN drupal_watchdog.referer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.referer IS 'URL of referring page.';


--
-- Name: COLUMN drupal_watchdog.hostname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog.hostname IS 'Hostname of the user who triggered the event.';


--
-- Name: COLUMN drupal_watchdog."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.drupal_watchdog."timestamp" IS 'Unix timestamp of when event occurred.';


--
-- Name: drupal_watchdog_wid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drupal_watchdog_wid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drupal_watchdog_wid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drupal_watchdog_wid_seq OWNED BY public.drupal_watchdog.wid;


--
-- Name: history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.history (
    event_time timestamp(2) without time zone,
    executed_by text,
    origin_value jsonb,
    new_value jsonb
);


--
-- Name: note_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.note_details AS
 SELECT "Note".id,
    "Note".id AS "noteId",
    "ChapterNote"."chapterId",
    "SubjectChapter"."subjectId" AS "SubjectId"
   FROM public."Note",
    public."ChapterNote",
    public."SubjectChapter"
  WHERE (("Note".id = "ChapterNote"."noteId") AND ("SubjectChapter"."chapterId" = "ChapterNote"."chapterId") AND ("SubjectChapter"."subjectId" = ANY (ARRAY[53, 54, 55, 56])));


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: student_coaches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_coaches (
    id bigint NOT NULL,
    "studentId" integer NOT NULL,
    "coachId" integer NOT NULL,
    role character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: student_coaches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.student_coaches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: student_coaches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.student_coaches_id_seq OWNED BY public.student_coaches.id;


--
-- Name: test; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test (
    a integer,
    b integer,
    c integer
);


--
-- Name: test_attempt_questions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.test_attempt_questions AS
 SELECT row_number() OVER (PARTITION BY "TestAttempt".id ORDER BY "TestQuestion"."seqNum", "Question".id) AS id,
    "TestAttempt"."testId",
    "TestAttempt".id AS "attemptId",
    "TestAttempt"."userId",
    "Answer"."userAnswer",
    "TestAttemptPostmartem".mistake,
    "TestAttemptPostmartem".action,
    "SubTopic1".name AS "subTopicName",
    "Topic".name AS "chapterName",
    "Subject".name AS "subjectName",
        CASE
            WHEN ("Answer"."userAnswer" = "Question"."correctOptionIndex") THEN true
            ELSE false
        END AS "isCorrect"
   FROM ((((((((public."TestAttempt"
     JOIN public."Test" ON ((("Test".id = "TestAttempt"."testId") AND ("TestAttempt".completed = true))))
     JOIN public."TestQuestion" ON (("TestQuestion"."testId" = "Test".id)))
     JOIN public."Question" ON (("Question".id = "TestQuestion"."questionId")))
     LEFT JOIN public."Answer" ON ((("TestAttempt".id = "Answer"."testAttemptId") AND ("Answer"."questionId" = "Question".id))))
     LEFT JOIN public."TestAttemptPostmartem" ON ((("TestAttemptPostmartem"."testAttemptId" = "TestAttempt".id) AND ("TestAttemptPostmartem"."questionId" = "Question".id))))
     LEFT JOIN LATERAL ( SELECT "SubTopic".name
           FROM public."QuestionSubTopic",
            public."SubTopic"
          WHERE (("QuestionSubTopic"."questionId" = "Question".id) AND ("QuestionSubTopic"."subTopicId" = "SubTopic".id))
         LIMIT 1) "SubTopic1" ON (true))
     LEFT JOIN public."Topic" ON (("Topic".id = "Question"."topicId")))
     LEFT JOIN public."Subject" ON (("Subject".id = "Question"."subjectId")));


--
-- Name: user_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_actions (
    id bigint NOT NULL,
    "userId" integer,
    count integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_actions_id_seq OWNED BY public.user_actions.id;


--
-- Name: usrs; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.usrs AS
 SELECT "User".id,
    "UserProfile"."displayName" AS name,
    "User".email,
    "UserProfile".picture AS avatar,
    "User"."blockedUser" AS blocked
   FROM public."User",
    public."UserProfile"
  WHERE ("User".id = "UserProfile"."userId");


--
-- Name: version_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_associations (
    id bigint NOT NULL,
    version_id integer,
    foreign_key_name character varying NOT NULL,
    foreign_key_id integer,
    foreign_type character varying
);


--
-- Name: version_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.version_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.version_associations_id_seq OWNED BY public.version_associations.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id bigint NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    whodunnit_type character varying DEFAULT 'admin'::character varying,
    transaction_id integer
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id bigint NOT NULL,
    votable_type character varying,
    votable_id bigint,
    voter_type character varying,
    voter_id bigint,
    vote_flag boolean,
    vote_scope character varying,
    vote_weight integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: work_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_logs (
    id bigint NOT NULL,
    start_time time without time zone,
    end_time time without time zone,
    date date NOT NULL,
    total_hours integer NOT NULL,
    content text,
    admin_user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: work_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_logs_id_seq OWNED BY public.work_logs.id;


--
-- Name: ActiveFlashCardChapter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActiveFlashCardChapter" ALTER COLUMN id SET DEFAULT nextval('public."ActiveFlashCardChapter_id_seq"'::regclass);


--
-- Name: Advertisement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Advertisement" ALTER COLUMN id SET DEFAULT nextval('public."Advertisement_id_seq"'::regclass);


--
-- Name: Announcement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Announcement" ALTER COLUMN id SET DEFAULT nextval('public."Announcement_id_seq"'::regclass);


--
-- Name: Answer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Answer" ALTER COLUMN id SET DEFAULT nextval('public."Answer_id_seq"'::regclass);


--
-- Name: AppVersion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AppVersion" ALTER COLUMN id SET DEFAULT nextval('public."AppVersion_id_seq"'::regclass);


--
-- Name: BookmarkQuestion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookmarkQuestion" ALTER COLUMN id SET DEFAULT nextval('public."BookmarkQuestion_id_seq"'::regclass);


--
-- Name: ChapterFlashCard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterFlashCard" ALTER COLUMN id SET DEFAULT nextval('public."ChapterFlashCard_id_seq"'::regclass);


--
-- Name: ChapterGlossary id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterGlossary" ALTER COLUMN id SET DEFAULT nextval('public."ChapterGlossary_id_seq"'::regclass);


--
-- Name: ChapterMindmap id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterMindmap" ALTER COLUMN id SET DEFAULT nextval('public."ChapterMindmap_id_seq"'::regclass);


--
-- Name: ChapterNote id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterNote" ALTER COLUMN id SET DEFAULT nextval('public."ChapterNote_id_seq"'::regclass);


--
-- Name: ChapterQuestionCopy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionCopy" ALTER COLUMN id SET DEFAULT nextval('public."ChapterQuestion_id_seq"'::regclass);


--
-- Name: ChapterQuestionSet id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionSet" ALTER COLUMN id SET DEFAULT nextval('public."ChapterQuestionSet_id_seq"'::regclass);


--
-- Name: ChapterTask id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTask" ALTER COLUMN id SET DEFAULT nextval('public."ChapterTask_id_seq"'::regclass);


--
-- Name: ChapterTest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTest" ALTER COLUMN id SET DEFAULT nextval('public."ChapterTest_id_seq"'::regclass);


--
-- Name: ChapterVideo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterVideo" ALTER COLUMN id SET DEFAULT nextval('public."ChapterVideo_id_seq"'::regclass);


--
-- Name: ChatAnswer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChatAnswer" ALTER COLUMN id SET DEFAULT nextval('public."ChatAnswer_id_seq"'::regclass);


--
-- Name: Comment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Comment" ALTER COLUMN id SET DEFAULT nextval('public."Comment_id_seq"'::regclass);


--
-- Name: ConfigValue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConfigValue" ALTER COLUMN id SET DEFAULT nextval('public."ConfigValue_id_seq"'::regclass);


--
-- Name: Constant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Constant" ALTER COLUMN id SET DEFAULT nextval('public."Constant_id_seq"'::regclass);


--
-- Name: CopyAnswer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CopyAnswer" ALTER COLUMN id SET DEFAULT nextval('public."CopyAnswer_id_seq"'::regclass);


--
-- Name: CopyTestAttempt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CopyTestAttempt" ALTER COLUMN id SET DEFAULT nextval('public."CopyTestAttempt_id_seq"'::regclass);


--
-- Name: Course id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Course" ALTER COLUMN id SET DEFAULT nextval('public."Course_id_seq"'::regclass);


--
-- Name: CourseDetail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseDetail" ALTER COLUMN id SET DEFAULT nextval('public."CourseDetail_id_seq"'::regclass);


--
-- Name: CourseInvitation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseInvitation" ALTER COLUMN id SET DEFAULT nextval('public."CourseInvitation_id_seq"'::regclass);


--
-- Name: CourseOffer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseOffer" ALTER COLUMN id SET DEFAULT nextval('public."CourseOffer_id_seq"'::regclass);


--
-- Name: CourseTest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseTest" ALTER COLUMN id SET DEFAULT nextval('public."CourseTest_id_seq"'::regclass);


--
-- Name: CourseTestimonial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseTestimonial" ALTER COLUMN id SET DEFAULT nextval('public."CourseTestimonial_id_seq"'::regclass);


--
-- Name: CustomerIssue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue" ALTER COLUMN id SET DEFAULT nextval('public."CustomerIssue_id_seq"'::regclass);


--
-- Name: CustomerIssueType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssueType" ALTER COLUMN id SET DEFAULT nextval('public."CustomerIssueType_id_seq"'::regclass);


--
-- Name: CustomerSupport id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerSupport" ALTER COLUMN id SET DEFAULT nextval('public."CustomerSupport_id_seq"'::regclass);


--
-- Name: DailyUserEvent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyUserEvent" ALTER COLUMN id SET DEFAULT nextval('public."DailyUserEvent_id_seq"'::regclass);


--
-- Name: Delivery id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Delivery" ALTER COLUMN id SET DEFAULT nextval('public."Delivery_id_seq"'::regclass);


--
-- Name: Doubt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Doubt" ALTER COLUMN id SET DEFAULT nextval('public."Doubt_id_seq"'::regclass);


--
-- Name: DoubtAnswer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DoubtAnswer" ALTER COLUMN id SET DEFAULT nextval('public."DoubtAnswer_id_seq"'::regclass);


--
-- Name: DuplicateChapter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicateChapter" ALTER COLUMN id SET DEFAULT nextval('public."DuplicateChapter_id_seq"'::regclass);


--
-- Name: DuplicatePost id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicatePost" ALTER COLUMN id SET DEFAULT nextval('public."DuplicatePost_id_seq"'::regclass);


--
-- Name: DuplicateQuestion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicateQuestion" ALTER COLUMN id SET DEFAULT nextval('public."DuplicateQuestion_id_seq"'::regclass);


--
-- Name: FcmToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FcmToken" ALTER COLUMN id SET DEFAULT nextval('public."FcmToken_id_seq"'::regclass);


--
-- Name: FestivalDiscount id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FestivalDiscount" ALTER COLUMN id SET DEFAULT nextval('public."FestivalDiscount_id_seq"'::regclass);


--
-- Name: FlashCard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlashCard" ALTER COLUMN id SET DEFAULT nextval('public."FlashCard_id_seq"'::regclass);


--
-- Name: Glossary id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Glossary" ALTER COLUMN id SET DEFAULT nextval('public."Glossary_id_seq"'::regclass);


--
-- Name: Group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Group" ALTER COLUMN id SET DEFAULT nextval('public."Group_id_seq"'::regclass);


--
-- Name: Installment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Installment" ALTER COLUMN id SET DEFAULT nextval('public."Installment_id_seq"'::regclass);


--
-- Name: Message id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Message" ALTER COLUMN id SET DEFAULT nextval('public."Message_id_seq"'::regclass);


--
-- Name: Motivation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Motivation" ALTER COLUMN id SET DEFAULT nextval('public."Motivation_id_seq"'::regclass);


--
-- Name: NCERTQuestion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NCERTQuestion" ALTER COLUMN id SET DEFAULT nextval('public."NCERTQuestion_id_seq"'::regclass);


--
-- Name: NEETExamResult id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NEETExamResult" ALTER COLUMN id SET DEFAULT nextval('public."NEETExamResult_id_seq"'::regclass);


--
-- Name: NcertChapterQuestion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertChapterQuestion" ALTER COLUMN id SET DEFAULT nextval('public."NcertChapterQuestion_id_seq"'::regclass);


--
-- Name: NcertSentence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertSentence" ALTER COLUMN id SET DEFAULT nextval('public."NcertSentence_id_seq"'::regclass);


--
-- Name: NksAppVersion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NksAppVersion" ALTER COLUMN id SET DEFAULT nextval('public."NksAppVersion_id_seq"'::regclass);


--
-- Name: NotDuplicateQuestion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotDuplicateQuestion" ALTER COLUMN id SET DEFAULT nextval('public."NotDuplicateQuestion_id_seq"'::regclass);


--
-- Name: Note id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Note" ALTER COLUMN id SET DEFAULT nextval('public."Note_id_seq"'::regclass);


--
-- Name: Notification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification" ALTER COLUMN id SET DEFAULT nextval('public."Notification_id_seq"'::regclass);


--
-- Name: OldCourseTest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OldCourseTest" ALTER COLUMN id SET DEFAULT nextval('public."OldCourseTest_id_seq"'::regclass);


--
-- Name: Payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment" ALTER COLUMN id SET DEFAULT nextval('public."Payment_id_seq"'::regclass);


--
-- Name: PaymentConversion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentConversion" ALTER COLUMN id SET DEFAULT nextval('public."PaymentConversion_id_seq"'::regclass);


--
-- Name: PaymentCourseInvitation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentCourseInvitation" ALTER COLUMN id SET DEFAULT nextval('public."PaymentCourseInvitation_id_seq"'::regclass);


--
-- Name: Post id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Post" ALTER COLUMN id SET DEFAULT nextval('public."Post_id_seq"'::regclass);


--
-- Name: Question id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question" ALTER COLUMN id SET DEFAULT nextval('public."Question_id_seq"'::regclass);


--
-- Name: QuestionDetail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionDetail" ALTER COLUMN id SET DEFAULT nextval('public."QuestionDetail_id_seq"'::regclass);


--
-- Name: QuestionExplanation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionExplanation" ALTER COLUMN id SET DEFAULT nextval('public."QuestionExplanation_id_seq"'::regclass);


--
-- Name: QuestionHint id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionHint" ALTER COLUMN id SET DEFAULT nextval('public."QuestionHint_id_seq"'::regclass);


--
-- Name: QuestionNcertSentence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionNcertSentence" ALTER COLUMN id SET DEFAULT nextval('public."QuestionNcertSentence_id_seq"'::regclass);


--
-- Name: QuestionSubTopic id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionSubTopic" ALTER COLUMN id SET DEFAULT nextval('public."QuestionSubTopic_id_seq"'::regclass);


--
-- Name: QuestionTranslation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionTranslation" ALTER COLUMN id SET DEFAULT nextval('public."QuestionTranslation_id_seq"'::regclass);


--
-- Name: QuestionVideoSentence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionVideoSentence" ALTER COLUMN id SET DEFAULT nextval('public."QuestionVideoSentence_id_seq"'::regclass);


--
-- Name: QuestionVimeo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionVimeo" ALTER COLUMN id SET DEFAULT nextval('public."QuestionVimeo_id_seq"'::regclass);


--
-- Name: Quiz id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quiz" ALTER COLUMN id SET DEFAULT nextval('public."Quiz_id_seq"'::regclass);


--
-- Name: RemovedSyllabusSubTopic id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RemovedSyllabusSubTopic" ALTER COLUMN id SET DEFAULT nextval('public."RemovedSyllabusSubTopic_id_seq"'::regclass);


--
-- Name: SEOData id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SEOData" ALTER COLUMN id SET DEFAULT nextval('public."SEOData_id_seq"'::regclass);


--
-- Name: Schedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Schedule" ALTER COLUMN id SET DEFAULT nextval('public."Schedule_id_seq"'::regclass);


--
-- Name: ScheduleItem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItem" ALTER COLUMN id SET DEFAULT nextval('public."ScheduleItem_id_seq"'::regclass);


--
-- Name: ScheduleItemAsset id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItemAsset" ALTER COLUMN id SET DEFAULT nextval('public."ScheduleItemAsset_id_seq"'::regclass);


--
-- Name: ScheduleItemUser id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItemUser" ALTER COLUMN id SET DEFAULT nextval('public."ScheduleItemUser_id_seq"'::regclass);


--
-- Name: ScheduledTask id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduledTask" ALTER COLUMN id SET DEFAULT nextval('public."ScheduledTask_id_seq"'::regclass);


--
-- Name: Section id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Section" ALTER COLUMN id SET DEFAULT nextval('public."Section_id_seq"'::regclass);


--
-- Name: SectionContent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SectionContent" ALTER COLUMN id SET DEFAULT nextval('public."SectionContent_id_seq"'::regclass);


--
-- Name: StudentNote id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudentNote" ALTER COLUMN id SET DEFAULT nextval('public."StudentNote_id_seq"'::regclass);


--
-- Name: StudentOnboardingEvents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudentOnboardingEvents" ALTER COLUMN id SET DEFAULT nextval('public."StudentOnboardingEvents_id_seq"'::regclass);


--
-- Name: SubTopic id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubTopic" ALTER COLUMN id SET DEFAULT nextval('public."SubTopic_id_seq"'::regclass);


--
-- Name: Subject id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Subject" ALTER COLUMN id SET DEFAULT nextval('public."Subject_id_seq"'::regclass);


--
-- Name: SubjectChapter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubjectChapter" ALTER COLUMN id SET DEFAULT nextval('public."SubjectChapter_id_seq"'::regclass);


--
-- Name: Target id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Target" ALTER COLUMN id SET DEFAULT nextval('public."Target_id_seq"'::regclass);


--
-- Name: TargetChapter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TargetChapter" ALTER COLUMN id SET DEFAULT nextval('public."TargetChapter_id_seq"'::regclass);


--
-- Name: Task id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Task" ALTER COLUMN id SET DEFAULT nextval('public."Task_id_seq"'::regclass);


--
-- Name: Test id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Test" ALTER COLUMN id SET DEFAULT nextval('public."Test_id_seq"'::regclass);


--
-- Name: TestAttempt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestAttempt" ALTER COLUMN id SET DEFAULT nextval('public."TestAttempt_id_seq"'::regclass);


--
-- Name: TestAttemptPostmartem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestAttemptPostmartem" ALTER COLUMN id SET DEFAULT nextval('public."TestAttemptPostmartem_id_seq"'::regclass);


--
-- Name: TestQuestion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestQuestion" ALTER COLUMN id SET DEFAULT nextval('public."TestQuestion_id_seq"'::regclass);


--
-- Name: Topic id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic" ALTER COLUMN id SET DEFAULT nextval('public."Topic_id_seq"'::regclass);


--
-- Name: TopicAssetOld id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TopicAssetOld" ALTER COLUMN id SET DEFAULT nextval('public."TopicAsset_id_seq"'::regclass);


--
-- Name: User id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- Name: UserChapterStat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserChapterStat" ALTER COLUMN id SET DEFAULT nextval('public."UserChapterStat_id_seq"'::regclass);


--
-- Name: UserClaim id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserClaim" ALTER COLUMN id SET DEFAULT nextval('public."UserClaim_id_seq"'::regclass);


--
-- Name: UserCourse id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserCourse" ALTER COLUMN id SET DEFAULT nextval('public."UserCourse_id_seq"'::regclass);


--
-- Name: UserDpp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserDpp" ALTER COLUMN id SET DEFAULT nextval('public."UserDpp_id_seq"'::regclass);


--
-- Name: UserFlashCard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFlashCard" ALTER COLUMN id SET DEFAULT nextval('public."UserFlashCard_id_seq"'::regclass);


--
-- Name: UserHighlightedNote id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserHighlightedNote" ALTER COLUMN id SET DEFAULT nextval('public."UserHighlightedNote_id_seq"'::regclass);


--
-- Name: UserLogin id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserLogin" ALTER COLUMN id SET DEFAULT nextval('public."UserLogin_id_seq"'::regclass);


--
-- Name: UserNoteStat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserNoteStat" ALTER COLUMN id SET DEFAULT nextval('public."UserNoteStat_id_seq"'::regclass);


--
-- Name: UserProfile id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserProfile" ALTER COLUMN id SET DEFAULT nextval('public."UserProfile_id_seq"'::regclass);


--
-- Name: UserResult id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserResult" ALTER COLUMN id SET DEFAULT nextval('public."UserResult_id_seq"'::regclass);


--
-- Name: UserScheduledTask id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserScheduledTask" ALTER COLUMN id SET DEFAULT nextval('public."UserScheduledTask_id_seq"'::regclass);


--
-- Name: UserSectionStat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserSectionStat" ALTER COLUMN id SET DEFAULT nextval('public."UserSectionStat_id_seq"'::regclass);


--
-- Name: UserTask id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTask" ALTER COLUMN id SET DEFAULT nextval('public."UserTask_id_seq"'::regclass);


--
-- Name: UserTodo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTodo" ALTER COLUMN id SET DEFAULT nextval('public."UserTodo_id_seq"'::regclass);


--
-- Name: UserVideoStat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserVideoStat" ALTER COLUMN id SET DEFAULT nextval('public."UserVideoStat_id_seq"'::regclass);


--
-- Name: Video id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Video" ALTER COLUMN id SET DEFAULT nextval('public."Video_id_seq"'::regclass);


--
-- Name: VideoAnnotation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoAnnotation" ALTER COLUMN id SET DEFAULT nextval('public."VideoAnnotation_id_seq"'::regclass);


--
-- Name: VideoLink id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoLink" ALTER COLUMN id SET DEFAULT nextval('public."VideoLink_id_seq"'::regclass);


--
-- Name: VideoQuestion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoQuestion" ALTER COLUMN id SET DEFAULT nextval('public."VideoQuestion_id_seq"'::regclass);


--
-- Name: VideoSentence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSentence" ALTER COLUMN id SET DEFAULT nextval('public."VideoSentence_id_seq"'::regclass);


--
-- Name: VideoSubTopic id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSubTopic" ALTER COLUMN id SET DEFAULT nextval('public."VideoSubTopic_id_seq"'::regclass);


--
-- Name: VideoTest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoTest" ALTER COLUMN id SET DEFAULT nextval('public."VideoTest_id_seq"'::regclass);


--
-- Name: Vote id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Vote" ALTER COLUMN id SET DEFAULT nextval('public."Vote_id_seq"'::regclass);


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: doubt_admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_admins ALTER COLUMN id SET DEFAULT nextval('public.doubt_admins_id_seq'::regclass);


--
-- Name: doubt_chat_channels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_chat_channels ALTER COLUMN id SET DEFAULT nextval('public.doubt_chat_channels_id_seq'::regclass);


--
-- Name: doubt_chat_doubt_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_chat_doubt_answers ALTER COLUMN id SET DEFAULT nextval('public.doubt_chat_doubt_answers_id_seq'::regclass);


--
-- Name: doubt_chat_doubts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_chat_doubts ALTER COLUMN id SET DEFAULT nextval('public.doubt_chat_doubts_id_seq'::regclass);


--
-- Name: drupal_block_content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content ALTER COLUMN id SET DEFAULT nextval('public.drupal_block_content_id_seq'::regclass);


--
-- Name: drupal_block_content_revision revision_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content_revision ALTER COLUMN revision_id SET DEFAULT nextval('public.drupal_block_content_revision_revision_id_seq'::regclass);


--
-- Name: drupal_comment cid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_comment ALTER COLUMN cid SET DEFAULT nextval('public.drupal_comment_cid_seq'::regclass);


--
-- Name: drupal_file_managed fid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_file_managed ALTER COLUMN fid SET DEFAULT nextval('public.drupal_file_managed_fid_seq'::regclass);


--
-- Name: drupal_h5p_content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_content ALTER COLUMN id SET DEFAULT nextval('public.drupal_h5p_content_id_seq'::regclass);


--
-- Name: drupal_h5p_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_events ALTER COLUMN id SET DEFAULT nextval('public.drupal_h5p_events_id_seq'::regclass);


--
-- Name: drupal_h5p_libraries library_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_libraries ALTER COLUMN library_id SET DEFAULT nextval('public.drupal_h5p_libraries_library_id_seq'::regclass);


--
-- Name: drupal_h5p_libraries_hub_cache id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_libraries_hub_cache ALTER COLUMN id SET DEFAULT nextval('public.drupal_h5p_libraries_hub_cache_id_seq'::regclass);


--
-- Name: drupal_menu_link_content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_link_content ALTER COLUMN id SET DEFAULT nextval('public.drupal_menu_link_content_id_seq'::regclass);


--
-- Name: drupal_menu_link_content_revision revision_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_link_content_revision ALTER COLUMN revision_id SET DEFAULT nextval('public.drupal_menu_link_content_revision_revision_id_seq'::regclass);


--
-- Name: drupal_menu_tree mlid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_tree ALTER COLUMN mlid SET DEFAULT nextval('public.drupal_menu_tree_mlid_seq'::regclass);


--
-- Name: drupal_node nid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node ALTER COLUMN nid SET DEFAULT nextval('public.drupal_node_nid_seq'::regclass);


--
-- Name: drupal_node_revision vid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_revision ALTER COLUMN vid SET DEFAULT nextval('public.drupal_node_revision_vid_seq'::regclass);


--
-- Name: drupal_path_alias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_path_alias ALTER COLUMN id SET DEFAULT nextval('public.drupal_path_alias_id_seq'::regclass);


--
-- Name: drupal_path_alias_revision revision_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_path_alias_revision ALTER COLUMN revision_id SET DEFAULT nextval('public.drupal_path_alias_revision_revision_id_seq'::regclass);


--
-- Name: drupal_queue item_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_queue ALTER COLUMN item_id SET DEFAULT nextval('public.drupal_queue_item_id_seq'::regclass);


--
-- Name: drupal_sequences value; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_sequences ALTER COLUMN value SET DEFAULT nextval('public.drupal_sequences_value_seq'::regclass);


--
-- Name: drupal_shortcut id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_shortcut ALTER COLUMN id SET DEFAULT nextval('public.drupal_shortcut_id_seq'::regclass);


--
-- Name: drupal_taxonomy_term_data tid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_data ALTER COLUMN tid SET DEFAULT nextval('public.drupal_taxonomy_term_data_tid_seq'::regclass);


--
-- Name: drupal_taxonomy_term_revision revision_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_revision ALTER COLUMN revision_id SET DEFAULT nextval('public.drupal_taxonomy_term_revision_revision_id_seq'::regclass);


--
-- Name: drupal_watchdog wid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_watchdog ALTER COLUMN wid SET DEFAULT nextval('public.drupal_watchdog_wid_seq'::regclass);


--
-- Name: student_coaches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_coaches ALTER COLUMN id SET DEFAULT nextval('public.student_coaches_id_seq'::regclass);


--
-- Name: user_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions ALTER COLUMN id SET DEFAULT nextval('public.user_actions_id_seq'::regclass);


--
-- Name: version_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_associations ALTER COLUMN id SET DEFAULT nextval('public.version_associations_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: work_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_logs ALTER COLUMN id SET DEFAULT nextval('public.work_logs_id_seq'::regclass);


--
-- Name: Question Question_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_pkey" PRIMARY KEY (id);


--
-- Name: QuestionAnalytics; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."QuestionAnalytics" AS
 SELECT "TempData".id,
    "TempData"."tagExist",
    "TempData"."correctAnswerCount",
    "TempData"."incorrectAnswerCount",
    "TempData"."option1AnswerCount",
    "TempData"."option2AnswerCount",
    "TempData"."option3AnswerCount",
    "TempData"."option4AnswerCount",
    "TempData"."incorrectReason1Count",
    "TempData"."incorrectReason2Count",
    "TempData"."incorrectReason3Count",
        CASE
            WHEN (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) THEN (((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric)
            ELSE NULL::numeric
        END AS "correctPercentage",
        CASE
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= ( SELECT ("Constant".value)::numeric AS value
               FROM public."Constant"
              WHERE ("Constant".key = 'CORRECT_PERCENTAGE_CEIL_MEDIUM'::text)))) THEN 'easy'::text
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= ( SELECT ("Constant".value)::numeric AS value
               FROM public."Constant"
              WHERE ("Constant".key = 'CORRECT_PERCENTAGE_CEIL_DIFFICULT'::text))) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) < ( SELECT ("Constant".value)::numeric AS value
               FROM public."Constant"
              WHERE ("Constant".key = 'CORRECT_PERCENTAGE_CEIL_MEDIUM'::text)))) THEN 'medium'::text
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (0)::numeric) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) < ( SELECT ("Constant".value)::numeric AS value
               FROM public."Constant"
              WHERE ("Constant".key = 'CORRECT_PERCENTAGE_CEIL_DIFFICULT'::text)))) THEN 'difficult'::text
            ELSE NULL::text
        END AS "difficultyLevel",
        CASE
            WHEN (EXISTS ( SELECT "Subject".id
               FROM public."TopicQuestion",
                public."Topic",
                public."Subject"
              WHERE (("TopicQuestion"."topicId" = "TempData".id) AND ("TopicQuestion"."topicId" = "Topic".id) AND ("Topic"."subjectId" = "Subject".id) AND ("Subject"."courseId" = 8)))) THEN true
            ELSE false
        END AS "inFullCourse"
   FROM ( SELECT "Question".id,
                CASE
                    WHEN (("Question".explanation ~~ '%<audio%'::text) OR ("Question".explanation ~~ '%<video%'::text)) THEN true
                    ELSE false
                END AS "tagExist",
            count(
                CASE
                    WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                    ELSE NULL::integer
                END) AS "correctAnswerCount",
            count(
                CASE
                    WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                    ELSE NULL::integer
                END) AS "incorrectAnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 0) THEN 1
                    ELSE NULL::integer
                END) AS "option1AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 1) THEN 1
                    ELSE NULL::integer
                END) AS "option2AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 2) THEN 1
                    ELSE NULL::integer
                END) AS "option3AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 3) THEN 1
                    ELSE NULL::integer
                END) AS "option4AnswerCount",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '1'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason1Count",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '2'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason2Count",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '3'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason3Count"
           FROM (public."Question"
             JOIN public."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question".type = ANY (ARRAY['MCQ-SO'::public."enum_Question_type", 'MCQ-AR'::public."enum_Question_type"])))))
          GROUP BY "Question".id) "TempData"
  WITH NO DATA;


--
-- Name: QuestionAnalytics11; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."QuestionAnalytics11" AS
 SELECT "TempData".id,
    "TempData"."tagExist",
    "TempData"."correctAnswerCount",
    "TempData"."incorrectAnswerCount",
    "TempData"."option1AnswerCount",
    "TempData"."option2AnswerCount",
    "TempData"."option3AnswerCount",
    "TempData"."option4AnswerCount",
    "TempData"."incorrectReason1Count",
    "TempData"."incorrectReason2Count",
    "TempData"."incorrectReason3Count",
        CASE
            WHEN (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) THEN (((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric)
            ELSE NULL::numeric
        END AS "correctPercentage",
        CASE
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (50)::numeric)) THEN 'easy'::text
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (25)::numeric) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) < (50)::numeric)) THEN 'medium'::text
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (0)::numeric) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) < (25)::numeric)) THEN 'difficult'::text
            ELSE NULL::text
        END AS "difficultyLevel",
        CASE
            WHEN (EXISTS ( SELECT "Subject".id
               FROM public."TopicQuestion",
                public."Topic",
                public."Subject"
              WHERE (("TopicQuestion"."topicId" = "TempData".id) AND ("TopicQuestion"."topicId" = "Topic".id) AND ("Topic"."subjectId" = "Subject".id) AND ("Subject"."courseId" = 8)))) THEN true
            ELSE false
        END AS "inFullCourse"
   FROM ( SELECT "Question".id,
                CASE
                    WHEN (("Question".explanation ~~ '%<audio%'::text) OR ("Question".explanation ~~ '%<video%'::text)) THEN true
                    ELSE false
                END AS "tagExist",
            count(
                CASE
                    WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                    ELSE NULL::integer
                END) AS "correctAnswerCount",
            count(
                CASE
                    WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                    ELSE NULL::integer
                END) AS "incorrectAnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 0) THEN 1
                    ELSE NULL::integer
                END) AS "option1AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 1) THEN 1
                    ELSE NULL::integer
                END) AS "option2AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 2) THEN 1
                    ELSE NULL::integer
                END) AS "option3AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 3) THEN 1
                    ELSE NULL::integer
                END) AS "option4AnswerCount",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '1'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason1Count",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '2'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason2Count",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '3'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason3Count"
           FROM (public."Question"
             LEFT JOIN public."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question".type = ANY (ARRAY['MCQ-SO'::public."enum_Question_type", 'MCQ-AR'::public."enum_Question_type"])))))
          GROUP BY "Question".id) "TempData"
  WITH NO DATA;


--
-- Name: QuestionAnalytics25; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."QuestionAnalytics25" AS
 SELECT "TempData".id,
    "TempData"."tagExist",
    "TempData"."correctAnswerCount",
    "TempData"."incorrectAnswerCount",
    "TempData"."option1AnswerCount",
    "TempData"."option2AnswerCount",
    "TempData"."option3AnswerCount",
    "TempData"."option4AnswerCount",
    "TempData"."incorrectReason1Count",
    "TempData"."incorrectReason2Count",
    "TempData"."incorrectReason3Count",
        CASE
            WHEN (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) THEN (((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric)
            ELSE NULL::numeric
        END AS "correctPercentage",
        CASE
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (50)::numeric)) THEN 'easy'::text
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (25)::numeric) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) < (50)::numeric)) THEN 'medium'::text
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (0)::numeric) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) < (25)::numeric)) THEN 'difficult'::text
            ELSE NULL::text
        END AS "difficultyLevel",
        CASE
            WHEN (EXISTS ( SELECT "Subject".id
               FROM public."TopicQuestion",
                public."Topic",
                public."Subject"
              WHERE (("TopicQuestion"."topicId" = "TempData".id) AND ("TopicQuestion"."topicId" = "Topic".id) AND ("Topic"."subjectId" = "Subject".id) AND ("Subject"."courseId" = 8)))) THEN true
            ELSE false
        END AS "inFullCourse"
   FROM ( SELECT "Question".id,
                CASE
                    WHEN (("Question".explanation ~~ '%<audio%'::text) OR ("Question".explanation ~~ '%<video%'::text)) THEN true
                    ELSE false
                END AS "tagExist",
            count(
                CASE
                    WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                    ELSE NULL::integer
                END) AS "correctAnswerCount",
            count(
                CASE
                    WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                    ELSE NULL::integer
                END) AS "incorrectAnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 0) THEN 1
                    ELSE NULL::integer
                END) AS "option1AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 1) THEN 1
                    ELSE NULL::integer
                END) AS "option2AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 2) THEN 1
                    ELSE NULL::integer
                END) AS "option3AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 3) THEN 1
                    ELSE NULL::integer
                END) AS "option4AnswerCount",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '1'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason1Count",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '2'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason2Count",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '3'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason3Count"
           FROM (public."Question"
             LEFT JOIN public."Answer" ON (("Question".id = "Answer"."questionId")))
          GROUP BY "Question".id) "TempData"
  WITH NO DATA;


--
-- Name: QuestionAnalytics26; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."QuestionAnalytics26" AS
 SELECT "TempData".id,
    "TempData"."tagExist",
    "TempData"."correctAnswerCount",
    "TempData"."incorrectAnswerCount",
    "TempData"."option1AnswerCount",
    "TempData"."option2AnswerCount",
    "TempData"."option3AnswerCount",
    "TempData"."option4AnswerCount",
    "TempData"."incorrectReason1Count",
    "TempData"."incorrectReason2Count",
    "TempData"."incorrectReason3Count",
        CASE
            WHEN (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) THEN (((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric)
            ELSE NULL::numeric
        END AS "correctPercentage",
        CASE
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (50)::numeric)) THEN 'easy'::text
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (25)::numeric) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) < (50)::numeric)) THEN 'medium'::text
            WHEN ((("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount") > 10) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) >= (0)::numeric) AND ((((("TempData"."correctAnswerCount")::numeric * 1.0) / (("TempData"."correctAnswerCount" + "TempData"."incorrectAnswerCount"))::numeric) * (100)::numeric) < (25)::numeric)) THEN 'difficult'::text
            ELSE NULL::text
        END AS "difficultyLevel",
        CASE
            WHEN (EXISTS ( SELECT "Subject".id
               FROM public."TopicQuestion",
                public."Topic",
                public."Subject"
              WHERE (("TopicQuestion"."topicId" = "TempData".id) AND ("TopicQuestion"."topicId" = "Topic".id) AND ("Topic"."subjectId" = "Subject".id) AND ("Subject"."courseId" = 8)))) THEN true
            ELSE false
        END AS "inFullCourse"
   FROM ( SELECT "Question".id,
                CASE
                    WHEN (("Question".explanation ~~ '%<audio%'::text) OR ("Question".explanation ~~ '%<video%'::text)) THEN true
                    ELSE false
                END AS "tagExist",
            count(
                CASE
                    WHEN ("Question"."correctOptionIndex" = "Answer"."userAnswer") THEN 1
                    ELSE NULL::integer
                END) AS "correctAnswerCount",
            count(
                CASE
                    WHEN ("Question"."correctOptionIndex" <> "Answer"."userAnswer") THEN 1
                    ELSE NULL::integer
                END) AS "incorrectAnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 0) THEN 1
                    ELSE NULL::integer
                END) AS "option1AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 1) THEN 1
                    ELSE NULL::integer
                END) AS "option2AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 2) THEN 1
                    ELSE NULL::integer
                END) AS "option3AnswerCount",
            count(
                CASE
                    WHEN ("Answer"."userAnswer" = 3) THEN 1
                    ELSE NULL::integer
                END) AS "option4AnswerCount",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '1'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason1Count",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '2'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason2Count",
            count(
                CASE
                    WHEN (("Answer"."incorrectAnswerReason")::text = '3'::text) THEN 1
                    ELSE NULL::integer
                END) AS "incorrectReason3Count"
           FROM (public."Question"
             JOIN public."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question".type = ANY (ARRAY['MCQ-SO'::public."enum_Question_type", 'MCQ-AR'::public."enum_Question_type"])))))
          GROUP BY "Question".id) "TempData"
  WITH NO DATA;


--
-- Name: TestAttempt TestAttempt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestAttempt"
    ADD CONSTRAINT "TestAttempt_pkey" PRIMARY KEY (id);


--
-- Name: TestLeaderBoard; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public."TestLeaderBoard" AS
 SELECT "TestLeaderBoardDataWithRank".id,
    "TestLeaderBoardDataWithRank".rank,
    "TestLeaderBoardDataWithRank"."testAttemptNo",
    "TestLeaderBoardDataWithRank"."userId",
    "TestLeaderBoardDataWithRank"."testId",
    "TestLeaderBoardDataWithRank"."testAttemptId",
    "TestLeaderBoardDataWithRank".score,
    "TestLeaderBoardDataWithRank"."correctAnswerCount",
    "TestLeaderBoardDataWithRank"."incorrectAnswerCount"
   FROM ( SELECT "TestLeaderBoardData"."testAttemptId" AS id,
            rank() OVER (PARTITION BY "TestLeaderBoardData"."testId" ORDER BY "TestLeaderBoardData".score DESC) AS rank,
            "TestLeaderBoardData"."testAttemptNo",
            "TestLeaderBoardData"."userId",
            "TestLeaderBoardData"."testId",
            "TestLeaderBoardData"."testAttemptId",
            "TestLeaderBoardData".score,
            "TestLeaderBoardData"."correctAnswerCount",
            "TestLeaderBoardData"."incorrectAnswerCount"
           FROM ( SELECT "TestAttempt"."userId",
                    "TestAttempt"."testId",
                    "TestAttempt".id AS "testAttemptId",
                    ("TestAttempt".result -> 'correctAnswerCount'::text) AS "correctAnswerCount",
                    ("TestAttempt".result -> 'incorrectAnswerCount'::text) AS "incorrectAnswerCount",
                    row_number() OVER (PARTITION BY "TestAttempt"."userId", "TestAttempt"."testId" ORDER BY "TestAttempt".id) AS "testAttemptNo",
                    (("TestAttempt".result ->> 'totalMarks'::text))::integer AS score
                   FROM public."TestAttempt",
                    public."Test"
                  WHERE (("TestAttempt"."testId" = "Test".id) AND ("Test"."userId" IS NULL) AND ("Test"."showAnswer" = true) AND ("TestAttempt".result IS NOT NULL) AND ("TestAttempt".completed = true))
                  GROUP BY "TestAttempt"."userId", "TestAttempt"."testId", "TestAttempt".id) "TestLeaderBoardData"
          WHERE ("TestLeaderBoardData"."testAttemptNo" = 1)) "TestLeaderBoardDataWithRank"
  WITH NO DATA;


--
-- Name: CAMPAIGN_PERFORMANCE_REPORT CAMPAIGN_PERFORMANCE_REPORT_pkey; Type: CONSTRAINT; Schema: google_ads; Owner: -
--

ALTER TABLE ONLY google_ads."CAMPAIGN_PERFORMANCE_REPORT"
    ADD CONSTRAINT "CAMPAIGN_PERFORMANCE_REPORT_pkey" PRIMARY KEY (__sdc_primary_key);


--
-- Name: ActiveFlashCardChapter ActiveFlashCardChapter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActiveFlashCardChapter"
    ADD CONSTRAINT "ActiveFlashCardChapter_pkey" PRIMARY KEY (id);


--
-- Name: Advertisement Advertisement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Advertisement"
    ADD CONSTRAINT "Advertisement_pkey" PRIMARY KEY (id);


--
-- Name: Announcement Announcement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Announcement"
    ADD CONSTRAINT "Announcement_pkey" PRIMARY KEY (id);


--
-- Name: Answer Answer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Answer"
    ADD CONSTRAINT "Answer_pkey" PRIMARY KEY (id);


--
-- Name: AppVersion AppVersion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AppVersion"
    ADD CONSTRAINT "AppVersion_pkey" PRIMARY KEY (id);


--
-- Name: BookmarkQuestion BookmarkQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookmarkQuestion"
    ADD CONSTRAINT "BookmarkQuestion_pkey" PRIMARY KEY (id);


--
-- Name: ChapterFlashCard ChapterFlashCard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterFlashCard"
    ADD CONSTRAINT "ChapterFlashCard_pkey" PRIMARY KEY (id);


--
-- Name: ChapterGlossary ChapterGlossary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterGlossary"
    ADD CONSTRAINT "ChapterGlossary_pkey" PRIMARY KEY (id);


--
-- Name: ChapterMindmap ChapterMindmap_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterMindmap"
    ADD CONSTRAINT "ChapterMindmap_pkey" PRIMARY KEY (id);


--
-- Name: ChapterName ChapterName_name_subjectId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterName"
    ADD CONSTRAINT "ChapterName_name_subjectId_key" UNIQUE (name, "subjectId");


--
-- Name: ChapterNote ChapterNote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterNote"
    ADD CONSTRAINT "ChapterNote_pkey" PRIMARY KEY (id);


--
-- Name: ChapterQuestionSet ChapterQuestionSet_chapterId_testId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionSet"
    ADD CONSTRAINT "ChapterQuestionSet_chapterId_testId_key" UNIQUE ("chapterId", "testId");


--
-- Name: ChapterQuestionSet ChapterQuestionSet_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionSet"
    ADD CONSTRAINT "ChapterQuestionSet_pkey" PRIMARY KEY (id);


--
-- Name: ChapterQuestion ChapterQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestion"
    ADD CONSTRAINT "ChapterQuestion_pkey" PRIMARY KEY (id);


--
-- Name: ChapterTask ChapterTask_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTask"
    ADD CONSTRAINT "ChapterTask_pkey" PRIMARY KEY (id);


--
-- Name: ChapterTest ChapterTest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTest"
    ADD CONSTRAINT "ChapterTest_pkey" PRIMARY KEY (id);


--
-- Name: ChapterVideo ChapterVideo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterVideo"
    ADD CONSTRAINT "ChapterVideo_pkey" PRIMARY KEY (id);


--
-- Name: ChatAnswer ChatAnswer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChatAnswer"
    ADD CONSTRAINT "ChatAnswer_pkey" PRIMARY KEY (id);


--
-- Name: Comment Comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Comment"
    ADD CONSTRAINT "Comment_pkey" PRIMARY KEY (id);


--
-- Name: ConfigValue ConfigValue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConfigValue"
    ADD CONSTRAINT "ConfigValue_pkey" PRIMARY KEY (id);


--
-- Name: Constant Constant_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Constant"
    ADD CONSTRAINT "Constant_key_key" UNIQUE (key);


--
-- Name: Constant Constant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Constant"
    ADD CONSTRAINT "Constant_pkey" PRIMARY KEY (id);


--
-- Name: CopyTestAttempt CopyTestAttempt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CopyTestAttempt"
    ADD CONSTRAINT "CopyTestAttempt_pkey" PRIMARY KEY (id);


--
-- Name: CourseDetail CourseDetail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseDetail"
    ADD CONSTRAINT "CourseDetail_pkey" PRIMARY KEY (id);


--
-- Name: CourseInvitation CourseInvitation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseInvitation"
    ADD CONSTRAINT "CourseInvitation_pkey" PRIMARY KEY (id);


--
-- Name: CourseOffer CourseOffer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseOffer"
    ADD CONSTRAINT "CourseOffer_pkey" PRIMARY KEY (id);


--
-- Name: CourseTest CourseTest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseTest"
    ADD CONSTRAINT "CourseTest_pkey" PRIMARY KEY (id);


--
-- Name: CourseTestimonial CourseTestimonial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseTestimonial"
    ADD CONSTRAINT "CourseTestimonial_pkey" PRIMARY KEY (id);


--
-- Name: Course Course_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Course"
    ADD CONSTRAINT "Course_pkey" PRIMARY KEY (id);


--
-- Name: CustomerIssueType CustomerIssueType_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssueType"
    ADD CONSTRAINT "CustomerIssueType_code_key" UNIQUE (code);


--
-- Name: CustomerIssueType CustomerIssueType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssueType"
    ADD CONSTRAINT "CustomerIssueType_pkey" PRIMARY KEY (id);


--
-- Name: CustomerIssue CustomerIssue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT "CustomerIssue_pkey" PRIMARY KEY (id);


--
-- Name: CustomerSupport CustomerSupport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerSupport"
    ADD CONSTRAINT "CustomerSupport_pkey" PRIMARY KEY (id);


--
-- Name: DailyUserEvent DailyUserEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyUserEvent"
    ADD CONSTRAINT "DailyUserEvent_pkey" PRIMARY KEY (id);


--
-- Name: DailyUserEvent DailyUserEvent_userId_eventDate_event_courseId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyUserEvent"
    ADD CONSTRAINT "DailyUserEvent_userId_eventDate_event_courseId_key" UNIQUE ("userId", "eventDate", event, "courseId");


--
-- Name: Delivery Delivery_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Delivery"
    ADD CONSTRAINT "Delivery_pkey" PRIMARY KEY (id);


--
-- Name: DoubtAnswer DoubtAnswer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DoubtAnswer"
    ADD CONSTRAINT "DoubtAnswer_pkey" PRIMARY KEY (id);


--
-- Name: Doubt Doubt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Doubt"
    ADD CONSTRAINT "Doubt_pkey" PRIMARY KEY (id);


--
-- Name: DuplicateChapter DuplicateChapter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicateChapter"
    ADD CONSTRAINT "DuplicateChapter_pkey" PRIMARY KEY (id);


--
-- Name: DuplicatePost DuplicatePost_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicatePost"
    ADD CONSTRAINT "DuplicatePost_pkey" PRIMARY KEY (id);


--
-- Name: DuplicateQuestion DuplicateQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicateQuestion"
    ADD CONSTRAINT "DuplicateQuestion_pkey" PRIMARY KEY (id);


--
-- Name: DuplicateQuestion DuplicateQuestion_questionId1_questionId2_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicateQuestion"
    ADD CONSTRAINT "DuplicateQuestion_questionId1_questionId2_key" UNIQUE ("questionId1", "questionId2");


--
-- Name: FcmToken FcmToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FcmToken"
    ADD CONSTRAINT "FcmToken_pkey" PRIMARY KEY (id);


--
-- Name: FestivalDiscount FestivalDiscount_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FestivalDiscount"
    ADD CONSTRAINT "FestivalDiscount_pkey" PRIMARY KEY (id);


--
-- Name: FlashCard FlashCard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlashCard"
    ADD CONSTRAINT "FlashCard_pkey" PRIMARY KEY (id);


--
-- Name: Glossary Glossary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Glossary"
    ADD CONSTRAINT "Glossary_pkey" PRIMARY KEY (id);


--
-- Name: Group Group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Group"
    ADD CONSTRAINT "Group_pkey" PRIMARY KEY (id);


--
-- Name: Installment Installment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Installment"
    ADD CONSTRAINT "Installment_pkey" PRIMARY KEY (id);


--
-- Name: Message Message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_pkey" PRIMARY KEY (id);


--
-- Name: Motivation Motivation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Motivation"
    ADD CONSTRAINT "Motivation_pkey" PRIMARY KEY (id);


--
-- Name: NCERTQuestion NCERTQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NCERTQuestion"
    ADD CONSTRAINT "NCERTQuestion_pkey" PRIMARY KEY (id);


--
-- Name: NEETExamResult NEETExamResult_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NEETExamResult"
    ADD CONSTRAINT "NEETExamResult_pkey" PRIMARY KEY (id);


--
-- Name: NcertChapterQuestion NcertChapterQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertChapterQuestion"
    ADD CONSTRAINT "NcertChapterQuestion_pkey" PRIMARY KEY (id);


--
-- Name: NcertSentence NcertSentence_noteId_sentence_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertSentence"
    ADD CONSTRAINT "NcertSentence_noteId_sentence_unique" UNIQUE ("noteId", sentence);


--
-- Name: NcertSentence NcertSentence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertSentence"
    ADD CONSTRAINT "NcertSentence_pkey" PRIMARY KEY (id);


--
-- Name: NksAppVersion NksAppVersion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NksAppVersion"
    ADD CONSTRAINT "NksAppVersion_pkey" PRIMARY KEY (id);


--
-- Name: NotDuplicateQuestion NotDuplicateQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotDuplicateQuestion"
    ADD CONSTRAINT "NotDuplicateQuestion_pkey" PRIMARY KEY (id);


--
-- Name: NotDuplicateQuestion NotDuplicateQuestion_questionId1_questionId2_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotDuplicateQuestion"
    ADD CONSTRAINT "NotDuplicateQuestion_questionId1_questionId2_key" UNIQUE ("questionId1", "questionId2");


--
-- Name: Note Note_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Note"
    ADD CONSTRAINT "Note_pkey" PRIMARY KEY (id);


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: OldCourseTest OldCourseTest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OldCourseTest"
    ADD CONSTRAINT "OldCourseTest_pkey" PRIMARY KEY (id);


--
-- Name: PaymentConversion PaymentConversion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentConversion"
    ADD CONSTRAINT "PaymentConversion_pkey" PRIMARY KEY (id);


--
-- Name: PaymentCourseInvitation PaymentCourseInvitation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentCourseInvitation"
    ADD CONSTRAINT "PaymentCourseInvitation_pkey" PRIMARY KEY (id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: Post Post_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Post"
    ADD CONSTRAINT "Post_pkey" PRIMARY KEY (id);


--
-- Name: Post Post_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Post"
    ADD CONSTRAINT "Post_url_key" UNIQUE (url);


--
-- Name: QuestionCourse QuestionCourse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionCourse"
    ADD CONSTRAINT "QuestionCourse_pkey" PRIMARY KEY ("questionId");


--
-- Name: QuestionDetail QuestionDetail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionDetail"
    ADD CONSTRAINT "QuestionDetail_pkey" PRIMARY KEY (id);


--
-- Name: QuestionDetail QuestionDetail_questionId_year_exam_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionDetail"
    ADD CONSTRAINT "QuestionDetail_questionId_year_exam_unique" UNIQUE ("questionId", year, exam);


--
-- Name: QuestionDetail QuestionDetail_questionId_year_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionDetail"
    ADD CONSTRAINT "QuestionDetail_questionId_year_unique" UNIQUE ("questionId", year);


--
-- Name: QuestionExplanation QuestionExplanation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionExplanation"
    ADD CONSTRAINT "QuestionExplanation_pkey" PRIMARY KEY (id);


--
-- Name: QuestionHint QuestionHint_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionHint"
    ADD CONSTRAINT "QuestionHint_pkey" PRIMARY KEY (id);


--
-- Name: QuestionNcertSentence QuestionNcertSentence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionNcertSentence"
    ADD CONSTRAINT "QuestionNcertSentence_pkey" PRIMARY KEY (id);


--
-- Name: QuestionNcertSentence QuestionNcertSentence_questionId_ncertSentenceId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionNcertSentence"
    ADD CONSTRAINT "QuestionNcertSentence_questionId_ncertSentenceId_key" UNIQUE ("questionId", "ncertSentenceId");


--
-- Name: QuestionSubTopic QuestionSubTopic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionSubTopic"
    ADD CONSTRAINT "QuestionSubTopic_pkey" PRIMARY KEY (id);


--
-- Name: QuestionSubTopic QuestionSubTopic_questionId_subtopicId_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionSubTopic"
    ADD CONSTRAINT "QuestionSubTopic_questionId_subtopicId_unique" UNIQUE ("questionId", "subTopicId");


--
-- Name: QuestionTranslation QuestionTranslation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionTranslation"
    ADD CONSTRAINT "QuestionTranslation_pkey" PRIMARY KEY (id);


--
-- Name: QuestionTranslation QuestionTranslation_questionId_language_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionTranslation"
    ADD CONSTRAINT "QuestionTranslation_questionId_language_key" UNIQUE ("questionId", language);


--
-- Name: QuestionVideoSentence QuestionVideoSentence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionVideoSentence"
    ADD CONSTRAINT "QuestionVideoSentence_pkey" PRIMARY KEY (id);


--
-- Name: QuestionVideoSentence QuestionVideoSentence_questionId_videoSentenceId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionVideoSentence"
    ADD CONSTRAINT "QuestionVideoSentence_questionId_videoSentenceId_key" UNIQUE ("videoSentenceId", "questionId");


--
-- Name: QuestionVimeo QuestionVimeo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionVimeo"
    ADD CONSTRAINT "QuestionVimeo_pkey" PRIMARY KEY (id);


--
-- Name: Quiz Quiz_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quiz"
    ADD CONSTRAINT "Quiz_pkey" PRIMARY KEY (id);


--
-- Name: RemovedSyllabusSubTopic RemovedSyllabusSubTopic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RemovedSyllabusSubTopic"
    ADD CONSTRAINT "RemovedSyllabusSubTopic_pkey" PRIMARY KEY (id);


--
-- Name: RemovedSyllabusSubTopic RemovedSyllabusSubTopic_subTopicId_year_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RemovedSyllabusSubTopic"
    ADD CONSTRAINT "RemovedSyllabusSubTopic_subTopicId_year_key" UNIQUE ("subTopicId", year);


--
-- Name: SEOData SEOData_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SEOData"
    ADD CONSTRAINT "SEOData_pkey" PRIMARY KEY (id);


--
-- Name: ScheduleItemAsset ScheduleItemAsset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItemAsset"
    ADD CONSTRAINT "ScheduleItemAsset_pkey" PRIMARY KEY (id);


--
-- Name: ScheduleItemUser ScheduleItemUser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItemUser"
    ADD CONSTRAINT "ScheduleItemUser_pkey" PRIMARY KEY (id);


--
-- Name: ScheduleItem ScheduleItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItem"
    ADD CONSTRAINT "ScheduleItem_pkey" PRIMARY KEY (id);


--
-- Name: Schedule Schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Schedule"
    ADD CONSTRAINT "Schedule_pkey" PRIMARY KEY (id);


--
-- Name: ScheduledTask ScheduledTask_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduledTask"
    ADD CONSTRAINT "ScheduledTask_pkey" PRIMARY KEY (id);


--
-- Name: SectionContent SectionContent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SectionContent"
    ADD CONSTRAINT "SectionContent_pkey" PRIMARY KEY (id);


--
-- Name: Section Section_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Section"
    ADD CONSTRAINT "Section_pkey" PRIMARY KEY (id);


--
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- Name: StudentNote StudentNoteNCERTHighlightNoOverlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudentNote"
    ADD CONSTRAINT "StudentNoteNCERTHighlightNoOverlap" EXCLUDE USING gist ("userId" WITH =, "noteId" WITH =, "noteRange" WITH &&);


--
-- Name: StudentNote StudentNote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudentNote"
    ADD CONSTRAINT "StudentNote_pkey" PRIMARY KEY (id);


--
-- Name: StudentOnboardingEvents StudentOnboardingEvents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudentOnboardingEvents"
    ADD CONSTRAINT "StudentOnboardingEvents_pkey" PRIMARY KEY (id);


--
-- Name: SubTopic SubTopic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubTopic"
    ADD CONSTRAINT "SubTopic_pkey" PRIMARY KEY (id);


--
-- Name: SubTopic SubTopic_topicId_name_deleted_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubTopic"
    ADD CONSTRAINT "SubTopic_topicId_name_deleted_unique" UNIQUE ("topicId", name, deleted);


--
-- Name: SubjectChapter SubjectChapter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubjectChapter"
    ADD CONSTRAINT "SubjectChapter_pkey" PRIMARY KEY (id);


--
-- Name: Subject Subject_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Subject"
    ADD CONSTRAINT "Subject_pkey" PRIMARY KEY (id);


--
-- Name: TargetChapter TargetChapter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TargetChapter"
    ADD CONSTRAINT "TargetChapter_pkey" PRIMARY KEY (id);


--
-- Name: Target Target_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Target"
    ADD CONSTRAINT "Target_pkey" PRIMARY KEY (id);


--
-- Name: Task Task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_pkey" PRIMARY KEY (id);


--
-- Name: TestAttemptPostmartem TestAttemptPostmartem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestAttemptPostmartem"
    ADD CONSTRAINT "TestAttemptPostmartem_pkey" PRIMARY KEY (id);


--
-- Name: TestQuestion TestQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestQuestion"
    ADD CONSTRAINT "TestQuestion_pkey" PRIMARY KEY (id);


--
-- Name: Test Test_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Test"
    ADD CONSTRAINT "Test_pkey" PRIMARY KEY (id);


--
-- Name: TopicAssetOld TopicAsset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TopicAssetOld"
    ADD CONSTRAINT "TopicAsset_pkey" PRIMARY KEY (id);


--
-- Name: Topic Topic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic"
    ADD CONSTRAINT "Topic_pkey" PRIMARY KEY (id);


--
-- Name: UserChapterStat UserChapterStat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserChapterStat"
    ADD CONSTRAINT "UserChapterStat_pkey" PRIMARY KEY (id);


--
-- Name: UserClaim UserClaim_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserClaim"
    ADD CONSTRAINT "UserClaim_pkey" PRIMARY KEY (id);


--
-- Name: UserCourse UserCourse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserCourse"
    ADD CONSTRAINT "UserCourse_pkey" PRIMARY KEY (id);


--
-- Name: UserDpp UserDpp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserDpp"
    ADD CONSTRAINT "UserDpp_pkey" PRIMARY KEY (id);


--
-- Name: UserFlashCard UserFlashCard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFlashCard"
    ADD CONSTRAINT "UserFlashCard_pkey" PRIMARY KEY (id);


--
-- Name: UserHighlightedNote UserHighlightedNote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserHighlightedNote"
    ADD CONSTRAINT "UserHighlightedNote_pkey" PRIMARY KEY (id);


--
-- Name: UserLogin UserLogin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserLogin"
    ADD CONSTRAINT "UserLogin_pkey" PRIMARY KEY (id);


--
-- Name: UserNoteStat UserNoteStat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserNoteStat"
    ADD CONSTRAINT "UserNoteStat_pkey" PRIMARY KEY (id);


--
-- Name: UserProfile UserProfile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserProfile"
    ADD CONSTRAINT "UserProfile_pkey" PRIMARY KEY (id);


--
-- Name: UserResult UserResult_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserResult"
    ADD CONSTRAINT "UserResult_pkey" PRIMARY KEY (id);


--
-- Name: UserScheduledTask UserScheduledTask_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserScheduledTask"
    ADD CONSTRAINT "UserScheduledTask_pkey" PRIMARY KEY (id);


--
-- Name: UserSectionStat UserSectionStat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserSectionStat"
    ADD CONSTRAINT "UserSectionStat_pkey" PRIMARY KEY (id);


--
-- Name: UserTask UserTask_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTask"
    ADD CONSTRAINT "UserTask_pkey" PRIMARY KEY (id);


--
-- Name: UserTodo UserTodo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTodo"
    ADD CONSTRAINT "UserTodo_pkey" PRIMARY KEY (id);


--
-- Name: UserVideoStat UserVideoStat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserVideoStat"
    ADD CONSTRAINT "UserVideoStat_pkey" PRIMARY KEY (id);


--
-- Name: User User_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_email_key" UNIQUE (email);


--
-- Name: User User_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_phone_key" UNIQUE (phone);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: VideoAnnotation VideoAnnotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoAnnotation"
    ADD CONSTRAINT "VideoAnnotation_pkey" PRIMARY KEY (id);


--
-- Name: VideoLink VideoLink_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoLink"
    ADD CONSTRAINT "VideoLink_pkey" PRIMARY KEY (id);


--
-- Name: VideoQuestion VideoQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoQuestion"
    ADD CONSTRAINT "VideoQuestion_pkey" PRIMARY KEY (id);


--
-- Name: VideoSentence VideoSentenceNoOverlap; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSentence"
    ADD CONSTRAINT "VideoSentenceNoOverlap" EXCLUDE USING gist ("videoId" WITH =, numrange(("timestampStart")::numeric, ("timestampEnd")::numeric, '[)'::text) WITH &&);


--
-- Name: VideoSentence VideoSentence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSentence"
    ADD CONSTRAINT "VideoSentence_pkey" PRIMARY KEY (id);


--
-- Name: VideoSentence VideoSentence_videoId_timestampStart_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSentence"
    ADD CONSTRAINT "VideoSentence_videoId_timestampStart_unique" UNIQUE ("videoId", "timestampStart");


--
-- Name: VideoSubTopic VideoSubTopic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSubTopic"
    ADD CONSTRAINT "VideoSubTopic_pkey" PRIMARY KEY (id);


--
-- Name: VideoTest VideoTest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoTest"
    ADD CONSTRAINT "VideoTest_pkey" PRIMARY KEY (id);


--
-- Name: Video Video_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Video"
    ADD CONSTRAINT "Video_pkey" PRIMARY KEY (id);


--
-- Name: Vote Vote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Vote"
    ADD CONSTRAINT "Vote_pkey" PRIMARY KEY (id);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: BookmarkQuestion bookmarkquestion_user_id_question_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookmarkQuestion"
    ADD CONSTRAINT bookmarkquestion_user_id_question_id UNIQUE ("userId", "questionId");


--
-- Name: ChapterNote chapternote_chapter_id_note_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterNote"
    ADD CONSTRAINT chapternote_chapter_id_note_id UNIQUE ("chapterId", "noteId");


--
-- Name: ChapterQuestion chapterquestion1_chapter_id_question_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestion"
    ADD CONSTRAINT chapterquestion1_chapter_id_question_id UNIQUE ("chapterId", "questionId");


--
-- Name: ChapterQuestionCopy chapterquestion_chapter_id_question_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionCopy"
    ADD CONSTRAINT chapterquestion_chapter_id_question_id UNIQUE ("chapterId", "questionId");


--
-- Name: ChapterTest chaptertest_chapter_id_test_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTest"
    ADD CONSTRAINT chaptertest_chapter_id_test_id UNIQUE ("chapterId", "testId");


--
-- Name: ChapterVideo chaptervideo_chapter_id_video_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterVideo"
    ADD CONSTRAINT chaptervideo_chapter_id_video_id UNIQUE ("chapterId", "videoId");


--
-- Name: doubt_admins doubt_admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_admins
    ADD CONSTRAINT doubt_admins_pkey PRIMARY KEY (id);


--
-- Name: doubt_chat_channels doubt_chat_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_chat_channels
    ADD CONSTRAINT doubt_chat_channels_pkey PRIMARY KEY (id);


--
-- Name: doubt_chat_doubt_answers doubt_chat_doubt_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_chat_doubt_answers
    ADD CONSTRAINT doubt_chat_doubt_answers_pkey PRIMARY KEY (id);


--
-- Name: doubt_chat_doubts doubt_chat_doubts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_chat_doubts
    ADD CONSTRAINT doubt_chat_doubts_pkey PRIMARY KEY (id);


--
-- Name: drupal_menu_link_content drupal_OUc_bIkVV_RMYM_IZJxmprmJQWZmml85XqJrLpH0luI_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_link_content
    ADD CONSTRAINT "drupal_OUc_bIkVV_RMYM_IZJxmprmJQWZmml85XqJrLpH0luI_key" UNIQUE (uuid);


--
-- Name: drupal_batch drupal_batch____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_batch
    ADD CONSTRAINT drupal_batch____pkey PRIMARY KEY (bid);


--
-- Name: drupal_block_content drupal_block_content____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content
    ADD CONSTRAINT drupal_block_content____pkey PRIMARY KEY (id);


--
-- Name: drupal_block_content drupal_block_content__block_content__revision_id__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content
    ADD CONSTRAINT drupal_block_content__block_content__revision_id__key UNIQUE (revision_id);


--
-- Name: drupal_block_content drupal_block_content__block_content_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content
    ADD CONSTRAINT drupal_block_content__block_content_field__uuid__value__key UNIQUE (uuid);


--
-- Name: drupal_block_content__body drupal_block_content__body____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content__body
    ADD CONSTRAINT drupal_block_content__body____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_block_content_field_data drupal_block_content_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content_field_data
    ADD CONSTRAINT drupal_block_content_field_data____pkey PRIMARY KEY (id, langcode);


--
-- Name: drupal_block_content_field_revision drupal_block_content_field_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content_field_revision
    ADD CONSTRAINT drupal_block_content_field_revision____pkey PRIMARY KEY (revision_id, langcode);


--
-- Name: drupal_block_content_revision drupal_block_content_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content_revision
    ADD CONSTRAINT drupal_block_content_revision____pkey PRIMARY KEY (revision_id);


--
-- Name: drupal_block_content_revision__body drupal_block_content_revision__body____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_block_content_revision__body
    ADD CONSTRAINT drupal_block_content_revision__body____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- Name: drupal_taxonomy_term_data drupal_c9dnKBdvoo2vdKAuSj5iFSeChEJtUzcWyY8AwqTRv6Q_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_data
    ADD CONSTRAINT "drupal_c9dnKBdvoo2vdKAuSj5iFSeChEJtUzcWyY8AwqTRv6Q_key" UNIQUE (uuid);


--
-- Name: drupal_cache_bootstrap drupal_cache_bootstrap____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_bootstrap
    ADD CONSTRAINT drupal_cache_bootstrap____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_config drupal_cache_config____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_config
    ADD CONSTRAINT drupal_cache_config____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_container drupal_cache_container____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_container
    ADD CONSTRAINT drupal_cache_container____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_data drupal_cache_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_data
    ADD CONSTRAINT drupal_cache_data____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_default drupal_cache_default____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_default
    ADD CONSTRAINT drupal_cache_default____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_discovery drupal_cache_discovery____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_discovery
    ADD CONSTRAINT drupal_cache_discovery____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_dynamic_page_cache drupal_cache_dynamic_page_cache____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_dynamic_page_cache
    ADD CONSTRAINT drupal_cache_dynamic_page_cache____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_entity drupal_cache_entity____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_entity
    ADD CONSTRAINT drupal_cache_entity____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_menu drupal_cache_menu____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_menu
    ADD CONSTRAINT drupal_cache_menu____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_page drupal_cache_page____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_page
    ADD CONSTRAINT drupal_cache_page____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_render drupal_cache_render____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_render
    ADD CONSTRAINT drupal_cache_render____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cache_toolbar drupal_cache_toolbar____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cache_toolbar
    ADD CONSTRAINT drupal_cache_toolbar____pkey PRIMARY KEY (cid);


--
-- Name: drupal_cachetags drupal_cachetags____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_cachetags
    ADD CONSTRAINT drupal_cachetags____pkey PRIMARY KEY (tag);


--
-- Name: drupal_comment drupal_comment____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_comment
    ADD CONSTRAINT drupal_comment____pkey PRIMARY KEY (cid);


--
-- Name: drupal_comment__comment_body drupal_comment__comment_body____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_comment__comment_body
    ADD CONSTRAINT drupal_comment__comment_body____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_comment drupal_comment__comment_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_comment
    ADD CONSTRAINT drupal_comment__comment_field__uuid__value__key UNIQUE (uuid);


--
-- Name: drupal_comment_entity_statistics drupal_comment_entity_statistics____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_comment_entity_statistics
    ADD CONSTRAINT drupal_comment_entity_statistics____pkey PRIMARY KEY (entity_id, entity_type, field_name);


--
-- Name: drupal_comment_field_data drupal_comment_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_comment_field_data
    ADD CONSTRAINT drupal_comment_field_data____pkey PRIMARY KEY (cid, langcode);


--
-- Name: drupal_config drupal_config____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_config
    ADD CONSTRAINT drupal_config____pkey PRIMARY KEY (collection, name);


--
-- Name: drupal_file_managed drupal_file_managed____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_file_managed
    ADD CONSTRAINT drupal_file_managed____pkey PRIMARY KEY (fid);


--
-- Name: drupal_file_managed drupal_file_managed__file_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_file_managed
    ADD CONSTRAINT drupal_file_managed__file_field__uuid__value__key UNIQUE (uuid);


--
-- Name: drupal_file_usage drupal_file_usage____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_file_usage
    ADD CONSTRAINT drupal_file_usage____pkey PRIMARY KEY (fid, type, id, module);


--
-- Name: drupal_h5p_content drupal_h5p_content____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_content
    ADD CONSTRAINT drupal_h5p_content____pkey PRIMARY KEY (id);


--
-- Name: drupal_h5p_content_libraries drupal_h5p_content_libraries____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_content_libraries
    ADD CONSTRAINT drupal_h5p_content_libraries____pkey PRIMARY KEY (content_id, library_id, dependency_type);


--
-- Name: drupal_h5p_content_user_data drupal_h5p_content_user_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_content_user_data
    ADD CONSTRAINT drupal_h5p_content_user_data____pkey PRIMARY KEY (user_id, content_main_id, sub_content_id, data_id);


--
-- Name: drupal_h5p_counters drupal_h5p_counters____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_counters
    ADD CONSTRAINT drupal_h5p_counters____pkey PRIMARY KEY (type, library_name, library_version);


--
-- Name: drupal_h5p_events drupal_h5p_events____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_events
    ADD CONSTRAINT drupal_h5p_events____pkey PRIMARY KEY (id);


--
-- Name: drupal_h5p_libraries drupal_h5p_libraries____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_libraries
    ADD CONSTRAINT drupal_h5p_libraries____pkey PRIMARY KEY (library_id);


--
-- Name: drupal_h5p_libraries_hub_cache drupal_h5p_libraries_hub_cache____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_libraries_hub_cache
    ADD CONSTRAINT drupal_h5p_libraries_hub_cache____pkey PRIMARY KEY (id);


--
-- Name: drupal_h5p_libraries_languages drupal_h5p_libraries_languages____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_libraries_languages
    ADD CONSTRAINT drupal_h5p_libraries_languages____pkey PRIMARY KEY (library_id, language_code);


--
-- Name: drupal_h5p_libraries_libraries drupal_h5p_libraries_libraries____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_libraries_libraries
    ADD CONSTRAINT drupal_h5p_libraries_libraries____pkey PRIMARY KEY (library_id, required_library_id);


--
-- Name: drupal_h5p_points drupal_h5p_points____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_h5p_points
    ADD CONSTRAINT drupal_h5p_points____pkey PRIMARY KEY (content_id, uid);


--
-- Name: drupal_history drupal_history____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_history
    ADD CONSTRAINT drupal_history____pkey PRIMARY KEY (uid, nid);


--
-- Name: drupal_key_value drupal_key_value____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_key_value
    ADD CONSTRAINT drupal_key_value____pkey PRIMARY KEY (collection, name);


--
-- Name: drupal_key_value_expire drupal_key_value_expire____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_key_value_expire
    ADD CONSTRAINT drupal_key_value_expire____pkey PRIMARY KEY (collection, name);


--
-- Name: drupal_menu_link_content drupal_menu_link_content____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_link_content
    ADD CONSTRAINT drupal_menu_link_content____pkey PRIMARY KEY (id);


--
-- Name: drupal_menu_link_content drupal_menu_link_content__menu_link_content__revision_id__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_link_content
    ADD CONSTRAINT drupal_menu_link_content__menu_link_content__revision_id__key UNIQUE (revision_id);


--
-- Name: drupal_menu_link_content_data drupal_menu_link_content_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_link_content_data
    ADD CONSTRAINT drupal_menu_link_content_data____pkey PRIMARY KEY (id, langcode);


--
-- Name: drupal_menu_link_content_field_revision drupal_menu_link_content_field_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_link_content_field_revision
    ADD CONSTRAINT drupal_menu_link_content_field_revision____pkey PRIMARY KEY (revision_id, langcode);


--
-- Name: drupal_menu_link_content_revision drupal_menu_link_content_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_link_content_revision
    ADD CONSTRAINT drupal_menu_link_content_revision____pkey PRIMARY KEY (revision_id);


--
-- Name: drupal_menu_tree drupal_menu_tree____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_tree
    ADD CONSTRAINT drupal_menu_tree____pkey PRIMARY KEY (mlid);


--
-- Name: drupal_menu_tree drupal_menu_tree__id__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_menu_tree
    ADD CONSTRAINT drupal_menu_tree__id__key UNIQUE (id);


--
-- Name: drupal_node drupal_node____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node
    ADD CONSTRAINT drupal_node____pkey PRIMARY KEY (nid);


--
-- Name: drupal_node__body drupal_node__body____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node__body
    ADD CONSTRAINT drupal_node__body____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_node__comment drupal_node__comment____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node__comment
    ADD CONSTRAINT drupal_node__comment____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_node__field_h5p drupal_node__field_h5p____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node__field_h5p
    ADD CONSTRAINT drupal_node__field_h5p____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_node__field_image drupal_node__field_image____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node__field_image
    ADD CONSTRAINT drupal_node__field_image____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_node__field_tags drupal_node__field_tags____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node__field_tags
    ADD CONSTRAINT drupal_node__field_tags____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_node drupal_node__node__vid__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node
    ADD CONSTRAINT drupal_node__node__vid__key UNIQUE (vid);


--
-- Name: drupal_node drupal_node__node_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node
    ADD CONSTRAINT drupal_node__node_field__uuid__value__key UNIQUE (uuid);


--
-- Name: drupal_node_access drupal_node_access____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_access
    ADD CONSTRAINT drupal_node_access____pkey PRIMARY KEY (nid, gid, realm, langcode);


--
-- Name: drupal_node_field_data drupal_node_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_field_data
    ADD CONSTRAINT drupal_node_field_data____pkey PRIMARY KEY (nid, langcode);


--
-- Name: drupal_node_field_revision drupal_node_field_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_field_revision
    ADD CONSTRAINT drupal_node_field_revision____pkey PRIMARY KEY (vid, langcode);


--
-- Name: drupal_node_revision drupal_node_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_revision
    ADD CONSTRAINT drupal_node_revision____pkey PRIMARY KEY (vid);


--
-- Name: drupal_node_revision__body drupal_node_revision__body____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_revision__body
    ADD CONSTRAINT drupal_node_revision__body____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- Name: drupal_node_revision__comment drupal_node_revision__comment____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_revision__comment
    ADD CONSTRAINT drupal_node_revision__comment____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- Name: drupal_node_revision__field_h5p drupal_node_revision__field_h5p____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_revision__field_h5p
    ADD CONSTRAINT drupal_node_revision__field_h5p____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- Name: drupal_node_revision__field_image drupal_node_revision__field_image____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_revision__field_image
    ADD CONSTRAINT drupal_node_revision__field_image____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- Name: drupal_node_revision__field_tags drupal_node_revision__field_tags____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_node_revision__field_tags
    ADD CONSTRAINT drupal_node_revision__field_tags____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- Name: drupal_path_alias drupal_path_alias____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_path_alias
    ADD CONSTRAINT drupal_path_alias____pkey PRIMARY KEY (id);


--
-- Name: drupal_path_alias drupal_path_alias__path_alias__revision_id__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_path_alias
    ADD CONSTRAINT drupal_path_alias__path_alias__revision_id__key UNIQUE (revision_id);


--
-- Name: drupal_path_alias drupal_path_alias__path_alias_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_path_alias
    ADD CONSTRAINT drupal_path_alias__path_alias_field__uuid__value__key UNIQUE (uuid);


--
-- Name: drupal_path_alias_revision drupal_path_alias_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_path_alias_revision
    ADD CONSTRAINT drupal_path_alias_revision____pkey PRIMARY KEY (revision_id);


--
-- Name: drupal_queue drupal_queue____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_queue
    ADD CONSTRAINT drupal_queue____pkey PRIMARY KEY (item_id);


--
-- Name: drupal_router drupal_router____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_router
    ADD CONSTRAINT drupal_router____pkey PRIMARY KEY (name);


--
-- Name: drupal_s3fs_file drupal_s3fs_file____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_s3fs_file
    ADD CONSTRAINT drupal_s3fs_file____pkey PRIMARY KEY (uri);


--
-- Name: drupal_search_dataset drupal_search_dataset____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_search_dataset
    ADD CONSTRAINT drupal_search_dataset____pkey PRIMARY KEY (sid, langcode, type);


--
-- Name: drupal_search_index drupal_search_index____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_search_index
    ADD CONSTRAINT drupal_search_index____pkey PRIMARY KEY (word, sid, langcode, type);


--
-- Name: drupal_search_total drupal_search_total____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_search_total
    ADD CONSTRAINT drupal_search_total____pkey PRIMARY KEY (word);


--
-- Name: drupal_semaphore drupal_semaphore____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_semaphore
    ADD CONSTRAINT drupal_semaphore____pkey PRIMARY KEY (name);


--
-- Name: drupal_sequences drupal_sequences____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_sequences
    ADD CONSTRAINT drupal_sequences____pkey PRIMARY KEY (value);


--
-- Name: drupal_sessions drupal_sessions____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_sessions
    ADD CONSTRAINT drupal_sessions____pkey PRIMARY KEY (sid);


--
-- Name: drupal_shortcut drupal_shortcut____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_shortcut
    ADD CONSTRAINT drupal_shortcut____pkey PRIMARY KEY (id);


--
-- Name: drupal_shortcut drupal_shortcut__shortcut_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_shortcut
    ADD CONSTRAINT drupal_shortcut__shortcut_field__uuid__value__key UNIQUE (uuid);


--
-- Name: drupal_shortcut_field_data drupal_shortcut_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_shortcut_field_data
    ADD CONSTRAINT drupal_shortcut_field_data____pkey PRIMARY KEY (id, langcode);


--
-- Name: drupal_shortcut_set_users drupal_shortcut_set_users____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_shortcut_set_users
    ADD CONSTRAINT drupal_shortcut_set_users____pkey PRIMARY KEY (uid);


--
-- Name: drupal_taxonomy_index drupal_taxonomy_index____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_index
    ADD CONSTRAINT drupal_taxonomy_index____pkey PRIMARY KEY (nid, tid);


--
-- Name: drupal_taxonomy_term__parent drupal_taxonomy_term__parent____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term__parent
    ADD CONSTRAINT drupal_taxonomy_term__parent____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_taxonomy_term_data drupal_taxonomy_term_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_data
    ADD CONSTRAINT drupal_taxonomy_term_data____pkey PRIMARY KEY (tid);


--
-- Name: drupal_taxonomy_term_data drupal_taxonomy_term_data__taxonomy_term__revision_id__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_data
    ADD CONSTRAINT drupal_taxonomy_term_data__taxonomy_term__revision_id__key UNIQUE (revision_id);


--
-- Name: drupal_taxonomy_term_field_data drupal_taxonomy_term_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_field_data
    ADD CONSTRAINT drupal_taxonomy_term_field_data____pkey PRIMARY KEY (tid, langcode);


--
-- Name: drupal_taxonomy_term_field_revision drupal_taxonomy_term_field_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_field_revision
    ADD CONSTRAINT drupal_taxonomy_term_field_revision____pkey PRIMARY KEY (revision_id, langcode);


--
-- Name: drupal_taxonomy_term_revision drupal_taxonomy_term_revision____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_revision
    ADD CONSTRAINT drupal_taxonomy_term_revision____pkey PRIMARY KEY (revision_id);


--
-- Name: drupal_taxonomy_term_revision__parent drupal_taxonomy_term_revision__parent____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_taxonomy_term_revision__parent
    ADD CONSTRAINT drupal_taxonomy_term_revision__parent____pkey PRIMARY KEY (entity_id, revision_id, deleted, delta, langcode);


--
-- Name: drupal_user__roles drupal_user__roles____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_user__roles
    ADD CONSTRAINT drupal_user__roles____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_user__user_picture drupal_user__user_picture____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_user__user_picture
    ADD CONSTRAINT drupal_user__user_picture____pkey PRIMARY KEY (entity_id, deleted, delta, langcode);


--
-- Name: drupal_users drupal_users____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_users
    ADD CONSTRAINT drupal_users____pkey PRIMARY KEY (uid);


--
-- Name: drupal_users drupal_users__user_field__uuid__value__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_users
    ADD CONSTRAINT drupal_users__user_field__uuid__value__key UNIQUE (uuid);


--
-- Name: drupal_users_data drupal_users_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_users_data
    ADD CONSTRAINT drupal_users_data____pkey PRIMARY KEY (uid, module, name);


--
-- Name: drupal_users_field_data drupal_users_field_data____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_users_field_data
    ADD CONSTRAINT drupal_users_field_data____pkey PRIMARY KEY (uid, langcode);


--
-- Name: drupal_users_field_data drupal_users_field_data__user__name__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_users_field_data
    ADD CONSTRAINT drupal_users_field_data__user__name__key UNIQUE (name, langcode);


--
-- Name: drupal_watchdog drupal_watchdog____pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drupal_watchdog
    ADD CONSTRAINT drupal_watchdog____pkey PRIMARY KEY (wid);


--
-- Name: NcertChapterQuestion ncert_chapterquestion_chapter_id_question_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertChapterQuestion"
    ADD CONSTRAINT ncert_chapterquestion_chapter_id_question_id UNIQUE ("chapterId", "questionId");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: CourseOffer single_applicable_course_offer; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseOffer"
    ADD CONSTRAINT single_applicable_course_offer UNIQUE ("courseId", email, "offerExpiryAt", title);


--
-- Name: student_coaches student_coaches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_coaches
    ADD CONSTRAINT student_coaches_pkey PRIMARY KEY (id);


--
-- Name: SubjectChapter subject_chapter_subject_id_chapter_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubjectChapter"
    ADD CONSTRAINT subject_chapter_subject_id_chapter_id UNIQUE ("chapterId", "subjectId");


--
-- Name: ScheduleItemUser u_schedule_item_user_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItemUser"
    ADD CONSTRAINT u_schedule_item_user_user UNIQUE ("scheduleItemId", "userId");


--
-- Name: UserLogin u_user_id_platform; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserLogin"
    ADD CONSTRAINT u_user_id_platform UNIQUE ("userId", platform);


--
-- Name: DuplicateChapter unique_origId_dupId; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicateChapter"
    ADD CONSTRAINT "unique_origId_dupId" UNIQUE ("origId", "dupId");


--
-- Name: NCERTQuestion unique_questionId; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NCERTQuestion"
    ADD CONSTRAINT "unique_questionId" UNIQUE ("questionId");


--
-- Name: SectionContent unique_section_content_entry; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SectionContent"
    ADD CONSTRAINT unique_section_content_entry UNIQUE ("sectionId", "contentId", "contentType");


--
-- Name: Vote unique_vote; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Vote"
    ADD CONSTRAINT unique_vote UNIQUE ("userId", "ownerId", "ownerType");


--
-- Name: user_actions user_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT user_actions_pkey PRIMARY KEY (id);


--
-- Name: UserChapterStat userchapterstat_user_id_chapter_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserChapterStat"
    ADD CONSTRAINT userchapterstat_user_id_chapter_id UNIQUE ("userId", "chapterId");


--
-- Name: UserNoteStat usernotestat_user_id_note_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserNoteStat"
    ADD CONSTRAINT usernotestat_user_id_note_id UNIQUE ("userId", "noteId");


--
-- Name: UserSectionStat usersectionstat_user_id_section_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserSectionStat"
    ADD CONSTRAINT usersectionstat_user_id_section_id UNIQUE ("userId", "sectionId");


--
-- Name: UserVideoStat uservideostat_user_id_video_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserVideoStat"
    ADD CONSTRAINT uservideostat_user_id_video_id UNIQUE ("userId", "videoId");


--
-- Name: version_associations version_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_associations
    ADD CONSTRAINT version_associations_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: work_logs work_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_logs
    ADD CONSTRAINT work_logs_pkey PRIMARY KEY (id);


--
-- Name: Advertisement_expiryAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Advertisement_expiryAt_idx" ON public."Advertisement" USING btree ("expiryAt");


--
-- Name: Advertisement_platform_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Advertisement_platform_idx" ON public."Advertisement" USING btree (platform);


--
-- Name: ChapterFlashCard_chapterId_flashCardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ChapterFlashCard_chapterId_flashCardId_idx" ON public."ChapterFlashCard" USING btree ("chapterId", "flashCardId");


--
-- Name: ChapterFlashCard_chapterId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChapterFlashCard_chapterId_idx" ON public."ChapterFlashCard" USING btree ("chapterId");


--
-- Name: ChapterFlashCard_flashCardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChapterFlashCard_flashCardId_idx" ON public."ChapterFlashCard" USING btree ("flashCardId");


--
-- Name: ChapterQuestionSet_chapterId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChapterQuestionSet_chapterId_idx" ON public."ChapterQuestionSet" USING btree ("chapterId");


--
-- Name: CourseOffer_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CourseOffer_email_idx" ON public."CourseOffer" USING btree (email);


--
-- Name: CourseOffer_email_phone_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CourseOffer_email_phone_idx" ON public."CourseOffer" USING btree (email, phone);


--
-- Name: CourseOffer_hidden_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CourseOffer_hidden_idx" ON public."CourseOffer" USING btree (hidden);


--
-- Name: CourseOffer_offerExpiryAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CourseOffer_offerExpiryAt_idx" ON public."CourseOffer" USING btree ("offerExpiryAt");


--
-- Name: CourseOffer_phone_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CourseOffer_phone_idx" ON public."CourseOffer" USING btree (phone);


--
-- Name: CourseTest_courseId_testId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CourseTest_courseId_testId_idx" ON public."CourseTest" USING btree ("courseId", "testId");


--
-- Name: CourseTestimonial_courseId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CourseTestimonial_courseId_idx" ON public."CourseTestimonial" USING btree ("courseId");


--
-- Name: Course_package; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Course_package" ON public."Course" USING btree (package);


--
-- Name: CustomerIssue_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CustomerIssue_questionId_idx" ON public."CustomerIssue" USING btree ("questionId");


--
-- Name: CustomerIssue_videoId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CustomerIssue_videoId_idx" ON public."CustomerIssue" USING btree ("videoId");


--
-- Name: DailyUserEvent_courseId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DailyUserEvent_courseId_idx" ON public."DailyUserEvent" USING btree ("courseId");


--
-- Name: DailyUserEvent_eventCount_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DailyUserEvent_eventCount_idx" ON public."DailyUserEvent" USING btree ("eventCount");


--
-- Name: DoubtAnswer_content_gin_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DoubtAnswer_content_gin_index" ON public."DoubtAnswer" USING gin (content public.gin_trgm_ops);


--
-- Name: Doubt_answer_doubt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Doubt_answer_doubt_id" ON public."DoubtAnswer" USING btree ("doubtId");


--
-- Name: Doubt_answer_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Doubt_answer_user_id" ON public."DoubtAnswer" USING btree ("userId");


--
-- Name: Doubt_content_gin_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Doubt_content_gin_index" ON public."Doubt" USING gin (content public.gin_trgm_ops);


--
-- Name: Doubt_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Doubt_created_at_idx" ON public."Doubt" USING btree ("createdAt");


--
-- Name: Doubt_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Doubt_question_id" ON public."Doubt" USING btree ("questionId");


--
-- Name: Doubt_topic_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Doubt_topic_id_idx" ON public."Doubt" USING btree ("topicId");


--
-- Name: Doubt_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Doubt_user_id" ON public."Doubt" USING btree ("userId");


--
-- Name: DuplicateChapter_dupId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DuplicateChapter_dupId_idx" ON public."DuplicateChapter" USING btree ("dupId");


--
-- Name: DuplicateChapter_dupId_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DuplicateChapter_dupId_idx1" ON public."DuplicateChapter" USING btree ("dupId");


--
-- Name: DuplicateChapter_origId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DuplicateChapter_origId_idx" ON public."DuplicateChapter" USING btree ("origId");


--
-- Name: DuplicateQuestion_questionId1_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DuplicateQuestion_questionId1_idx" ON public."DuplicateQuestion" USING btree ("questionId1");


--
-- Name: DuplicateQuestion_questionId2_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DuplicateQuestion_questionId2_idx" ON public."DuplicateQuestion" USING btree ("questionId2");


--
-- Name: DuplicateQuestion_similarity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DuplicateQuestion_similarity_idx" ON public."DuplicateQuestion" USING btree (similarity);


--
-- Name: FcmToken_platform_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "FcmToken_platform_idx" ON public."FcmToken" USING btree (platform);


--
-- Name: FcmToken_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "FcmToken_userId_idx" ON public."FcmToken" USING btree ("userId");


--
-- Name: NCERTQuestion_questionId_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "NCERTQuestion_questionId_idx1" ON public."NCERTQuestion" USING btree ("questionId");


--
-- Name: NcertSentence_chapterId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NcertSentence_chapterId_idx" ON public."NcertSentence" USING btree ("chapterId");


--
-- Name: NcertSentence_sentence_gin_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NcertSentence_sentence_gin_index" ON public."NcertSentence" USING gin (sentence public.gin_trgm_ops);


--
-- Name: Payment_amount_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Payment_amount_idx" ON public."Payment" USING btree (amount);


--
-- Name: Payment_paymentDesc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Payment_paymentDesc_idx" ON public."Payment" USING btree ("paymentDesc");


--
-- Name: Payment_paymentMode_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Payment_paymentMode_idx" ON public."Payment" USING btree ("paymentMode");


--
-- Name: Payment_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Payment_status_idx" ON public."Payment" USING btree (status);


--
-- Name: Payment_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Payment_userId_idx" ON public."Payment" USING btree ("userId");


--
-- Name: QuestionAnalytics11_correctPercentage_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics11_correctPercentage_idx" ON public."QuestionAnalytics11" USING btree ("correctPercentage");


--
-- Name: QuestionAnalytics11_difficultyLevel_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics11_difficultyLevel_idx" ON public."QuestionAnalytics11" USING btree ("difficultyLevel");


--
-- Name: QuestionAnalytics11_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuestionAnalytics11_id_idx" ON public."QuestionAnalytics11" USING btree (id);


--
-- Name: QuestionAnalytics11_inFullCourse_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics11_inFullCourse_idx" ON public."QuestionAnalytics11" USING btree ("inFullCourse");


--
-- Name: QuestionAnalytics11_incorrectReason1Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics11_incorrectReason1Count_idx" ON public."QuestionAnalytics11" USING btree ("incorrectReason1Count");


--
-- Name: QuestionAnalytics11_incorrectReason2Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics11_incorrectReason2Count_idx" ON public."QuestionAnalytics11" USING btree ("incorrectReason2Count");


--
-- Name: QuestionAnalytics11_incorrectReason3Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics11_incorrectReason3Count_idx" ON public."QuestionAnalytics11" USING btree ("incorrectReason3Count");


--
-- Name: QuestionAnalytics11_tagExist_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics11_tagExist_idx" ON public."QuestionAnalytics11" USING btree ("tagExist");


--
-- Name: QuestionAnalytics12_correctPercentage_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics12_correctPercentage_idx" ON public."QuestionAnalytics26" USING btree ("correctPercentage");


--
-- Name: QuestionAnalytics12_difficultyLevel_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics12_difficultyLevel_idx" ON public."QuestionAnalytics26" USING btree ("difficultyLevel");


--
-- Name: QuestionAnalytics12_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics12_id_idx" ON public."QuestionAnalytics26" USING btree (id);


--
-- Name: QuestionAnalytics12_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuestionAnalytics12_id_idx1" ON public."QuestionAnalytics26" USING btree (id);


--
-- Name: QuestionAnalytics12_inFullCourse_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics12_inFullCourse_idx" ON public."QuestionAnalytics26" USING btree ("inFullCourse");


--
-- Name: QuestionAnalytics12_incorrectReason1Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics12_incorrectReason1Count_idx" ON public."QuestionAnalytics26" USING btree ("incorrectReason1Count");


--
-- Name: QuestionAnalytics12_incorrectReason2Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics12_incorrectReason2Count_idx" ON public."QuestionAnalytics26" USING btree ("incorrectReason2Count");


--
-- Name: QuestionAnalytics12_incorrectReason3Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics12_incorrectReason3Count_idx" ON public."QuestionAnalytics26" USING btree ("incorrectReason3Count");


--
-- Name: QuestionAnalytics12_tagExist_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics12_tagExist_idx" ON public."QuestionAnalytics26" USING btree ("tagExist");


--
-- Name: QuestionAnalytics13_correctPercentage_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics13_correctPercentage_idx" ON public."QuestionAnalytics" USING btree ("correctPercentage");


--
-- Name: QuestionAnalytics13_difficultyLevel_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics13_difficultyLevel_idx" ON public."QuestionAnalytics" USING btree ("difficultyLevel");


--
-- Name: QuestionAnalytics13_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuestionAnalytics13_id_idx" ON public."QuestionAnalytics" USING btree (id);


--
-- Name: QuestionAnalytics13_inFullCourse_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics13_inFullCourse_idx" ON public."QuestionAnalytics" USING btree ("inFullCourse");


--
-- Name: QuestionAnalytics13_incorrectReason1Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics13_incorrectReason1Count_idx" ON public."QuestionAnalytics" USING btree ("incorrectReason1Count");


--
-- Name: QuestionAnalytics13_incorrectReason2Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics13_incorrectReason2Count_idx" ON public."QuestionAnalytics" USING btree ("incorrectReason2Count");


--
-- Name: QuestionAnalytics13_incorrectReason3Count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics13_incorrectReason3Count_idx" ON public."QuestionAnalytics" USING btree ("incorrectReason3Count");


--
-- Name: QuestionAnalytics13_tagExist_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionAnalytics13_tagExist_idx" ON public."QuestionAnalytics" USING btree ("tagExist");


--
-- Name: QuestionAnalytics_id25; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuestionAnalytics_id25" ON public."QuestionAnalytics25" USING btree (id);


--
-- Name: QuestionCourse_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionCourse_questionId_idx" ON public."QuestionCourse" USING btree ("questionId");


--
-- Name: QuestionDetail_questionId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionDetail_questionId" ON public."QuestionDetail" USING btree ("questionId");


--
-- Name: QuestionExplanation_courseId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionExplanation_courseId_idx" ON public."QuestionExplanation" USING btree ("courseId");


--
-- Name: QuestionExplanation_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionExplanation_questionId_idx" ON public."QuestionExplanation" USING btree ("questionId");


--
-- Name: QuestionHint_courseId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionHint_courseId_idx" ON public."QuestionHint" USING btree ("courseId");


--
-- Name: QuestionHint_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionHint_questionId_idx" ON public."QuestionHint" USING btree ("questionId");


--
-- Name: QuestionNcertSentence_ncertSentenceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionNcertSentence_ncertSentenceId_idx" ON public."QuestionNcertSentence" USING btree ("ncertSentenceId");


--
-- Name: QuestionNcertSentence_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionNcertSentence_questionId_idx" ON public."QuestionNcertSentence" USING btree ("questionId");


--
-- Name: QuestionTranslation_questionId_language_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuestionTranslation_questionId_language_idx" ON public."QuestionTranslation" USING btree ("questionId", language);


--
-- Name: QuestionVideoSentence_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionVideoSentence_questionId_idx" ON public."QuestionVideoSentence" USING btree ("questionId");


--
-- Name: QuestionVideoSentence_videoSentenceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuestionVideoSentence_videoSentenceId_idx" ON public."QuestionVideoSentence" USING btree ("videoSentenceId");


--
-- Name: Question_ncert_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Question_ncert_idx" ON public."Question" USING btree (ncert);


--
-- Name: Question_paidAccess_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Question_paidAccess_idx" ON public."Question" USING btree ("paidAccess");


--
-- Name: Question_topicId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Question_topicId_idx" ON public."Question" USING btree ("topicId");


--
-- Name: Question_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Question_type_idx" ON public."Question" USING btree (type);


--
-- Name: ScheduleItem_scheduleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScheduleItem_scheduleId_idx" ON public."ScheduleItem" USING btree ("scheduleId");


--
-- Name: ScheduleItem_scheduledAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScheduleItem_scheduledAt_idx" ON public."ScheduleItem" USING btree ("scheduledAt");


--
-- Name: SelfCourseInvitationAccess; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SelfCourseInvitationAccess" ON public."CourseInvitation" USING btree (email, "courseId") WHERE ((admin_user_id IS NULL) AND ("createdAt" > '2020-09-09 00:00:00+00'::timestamp with time zone));


--
-- Name: StudentNote_flashcardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StudentNote_flashcardId_idx" ON public."StudentNote" USING btree ("flashcardId");


--
-- Name: StudentNote_noteId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StudentNote_noteId_idx" ON public."StudentNote" USING btree ("noteId");


--
-- Name: StudentNote_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StudentNote_questionId_idx" ON public."StudentNote" USING btree ("questionId");


--
-- Name: StudentNote_userId_flashcardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StudentNote_userId_flashcardId_idx" ON public."StudentNote" USING btree ("userId", "flashcardId");


--
-- Name: StudentNote_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StudentNote_userId_idx" ON public."StudentNote" USING btree ("userId");


--
-- Name: StudentNote_userId_noteId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StudentNote_userId_noteId_idx" ON public."StudentNote" USING btree ("userId", "noteId");


--
-- Name: StudentNote_userId_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StudentNote_userId_questionId_idx" ON public."StudentNote" USING btree ("userId", "questionId");


--
-- Name: SubTopic_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubTopic_deleted_idx" ON public."SubTopic" USING btree (deleted);


--
-- Name: SubTopic_topicId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubTopic_topicId" ON public."SubTopic" USING btree ("topicId");


--
-- Name: SubTopic_topicId_name_deleted_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SubTopic_topicId_name_deleted_idx1" ON public."SubTopic" USING btree ("topicId", name, deleted);


--
-- Name: SubTopic_videoOnly_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubTopic_videoOnly_idx" ON public."SubTopic" USING btree ("videoOnly");


--
-- Name: SubjectChapter_chapterId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubjectChapter_chapterId_idx" ON public."SubjectChapter" USING btree ("chapterId");


--
-- Name: SubjectChapter_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubjectChapter_deleted_idx" ON public."SubjectChapter" USING btree (deleted);


--
-- Name: SubjectChapter_subjectId_chapterId_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubjectChapter_subjectId_chapterId_deleted_idx" ON public."SubjectChapter" USING btree ("subjectId", "chapterId", deleted);


--
-- Name: SubjectChapter_subjectId_chapterId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubjectChapter_subjectId_chapterId_idx" ON public."SubjectChapter" USING btree ("subjectId", "chapterId");


--
-- Name: SubjectChapter_subjectId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubjectChapter_subjectId_idx" ON public."SubjectChapter" USING btree ("subjectId");


--
-- Name: Subject_courseId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Subject_courseId" ON public."Subject" USING btree ("courseId");


--
-- Name: TargetChapter_chapterId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TargetChapter_chapterId_idx" ON public."TargetChapter" USING btree ("chapterId");


--
-- Name: TargetChapter_targetId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TargetChapter_targetId_idx" ON public."TargetChapter" USING btree ("targetId");


--
-- Name: Target_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Target_status_idx" ON public."Target" USING btree (status);


--
-- Name: Target_testId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Target_testId_idx" ON public."Target" USING btree ("testId");


--
-- Name: Target_updatedAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Target_updatedAt_idx" ON public."Target" USING btree ("updatedAt");


--
-- Name: Target_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Target_userId_idx" ON public."Target" USING btree ("userId");


--
-- Name: Target_userId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Target_userId_status_idx" ON public."Target" USING btree ("userId", status);


--
-- Name: TestAttemptPostmartem_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TestAttemptPostmartem_questionId_idx" ON public."TestAttemptPostmartem" USING btree ("questionId");


--
-- Name: TestAttemptPostmartem_testAttemptId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TestAttemptPostmartem_testAttemptId_idx" ON public."TestAttemptPostmartem" USING btree ("testAttemptId");


--
-- Name: TestAttemptPostmartem_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TestAttemptPostmartem_userId_idx" ON public."TestAttemptPostmartem" USING btree ("userId");


--
-- Name: TestQuestion_testId_questionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TestQuestion_testId_questionId_idx" ON public."TestQuestion" USING btree ("testId", "questionId");


--
-- Name: Test_exam_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Test_exam_idx" ON public."Test" USING btree (exam);


--
-- Name: Test_expiryAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Test_expiryAt_idx" ON public."Test" USING btree ("expiryAt");


--
-- Name: Test_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Test_userId_idx" ON public."Test" USING btree ("userId");


--
-- Name: Topic_free_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Topic_free_idx" ON public."Topic" USING btree (free);


--
-- Name: Topic_subjectId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Topic_subjectId" ON public."Topic" USING btree ("subjectId");


--
-- Name: UserCourse_courseId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserCourse_courseId" ON public."UserCourse" USING btree ("courseId");


--
-- Name: UserCourse_courseId_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserCourse_courseId_userId_idx" ON public."UserCourse" USING btree ("courseId", "userId");


--
-- Name: UserCourse_expiryAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserCourse_expiryAt_idx" ON public."UserCourse" USING btree ("expiryAt");


--
-- Name: UserCourse_startedAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserCourse_startedAt_idx" ON public."UserCourse" USING btree ("startedAt");


--
-- Name: UserCourse_userId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserCourse_userId" ON public."UserCourse" USING btree ("userId");


--
-- Name: UserDpp_testId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserDpp_testId_idx" ON public."UserDpp" USING btree ("testId");


--
-- Name: UserDpp_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserDpp_userId_idx" ON public."UserDpp" USING btree ("userId");


--
-- Name: UserFlashCard_flashCardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserFlashCard_flashCardId_idx" ON public."UserFlashCard" USING btree ("flashCardId");


--
-- Name: UserFlashCard_userId_flashCardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserFlashCard_userId_flashCardId_idx" ON public."UserFlashCard" USING btree ("userId", "flashCardId");


--
-- Name: UserFlashCard_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserFlashCard_userId_idx" ON public."UserFlashCard" USING btree ("userId");


--
-- Name: VideoSentence_chapterId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VideoSentence_chapterId_idx" ON public."VideoSentence" USING btree ("chapterId");


--
-- Name: VideoSentence_videoId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VideoSentence_videoId_idx" ON public."VideoSentence" USING btree ("videoId");


--
-- Name: VideoSentence_videoId_timestampStart_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VideoSentence_videoId_timestampStart_idx" ON public."VideoSentence" USING btree ("videoId", "timestampStart");


--
-- Name: announcement_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX announcement_course_id ON public."Announcement" USING btree ("courseId");


--
-- Name: announcement_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX announcement_user_id ON public."Announcement" USING btree ("userId");


--
-- Name: answer_incorrect_answer_reason; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX answer_incorrect_answer_reason ON public."Answer" USING btree ("incorrectAnswerReason");


--
-- Name: answer_question_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX answer_question_idx ON public."Answer" USING btree ("questionId");


--
-- Name: answer_test_attempt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX answer_test_attempt_id ON public."Answer" USING btree ("testAttemptId");


--
-- Name: answer_user_id_question_id_test_attempt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX answer_user_id_question_id_test_attempt_id ON public."Answer" USING btree ("userId", "questionId", "testAttemptId");


--
-- Name: bookmark_question_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookmark_question_question_id ON public."BookmarkQuestion" USING btree ("questionId");


--
-- Name: bookmark_question_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookmark_question_user_id ON public."BookmarkQuestion" USING btree ("userId");


--
-- Name: chapter_note_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_note_chapter_id ON public."ChapterNote" USING btree ("chapterId");


--
-- Name: chapter_note_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_note_note_id ON public."ChapterNote" USING btree ("noteId");


--
-- Name: chapter_question_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_question_chapter_id ON public."ChapterQuestion" USING btree ("chapterId");


--
-- Name: chapter_question_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_question_question_id ON public."ChapterQuestion" USING btree ("questionId");


--
-- Name: chapter_task_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_task_chapter_id ON public."ChapterTask" USING btree ("chapterId");


--
-- Name: chapter_task_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_task_task_id ON public."ChapterTask" USING btree ("taskId");


--
-- Name: chapter_test_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_test_chapter_id ON public."ChapterTest" USING btree ("chapterId");


--
-- Name: chapter_test_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_test_test_id ON public."ChapterTest" USING btree ("testId");


--
-- Name: chapter_video_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_video_chapter_id ON public."ChapterVideo" USING btree ("chapterId");


--
-- Name: chapter_video_stat_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_video_stat_chapter_id ON public."ChapterVideoStat" USING btree ("chapterId");


--
-- Name: chapter_video_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chapter_video_video_id ON public."ChapterVideo" USING btree ("videoId");


--
-- Name: common_topic_leader_board_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX common_topic_leader_board_user_id ON public."CommonLeaderBoard" USING btree ("userId");


--
-- Name: correctPercentage10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "correctPercentage10" ON public."QuestionAnalytics25" USING btree ("correctPercentage");


--
-- Name: course_invitation_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX course_invitation_course_id ON public."CourseInvitation" USING btree ("courseId");


--
-- Name: course_invitation_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX course_invitation_email ON public."CourseInvitation" USING btree (email);


--
-- Name: course_invitation_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX course_invitation_phone ON public."CourseInvitation" USING btree (phone);


--
-- Name: course_offer_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX course_offer_course_id ON public."CourseOffer" USING btree ("courseId");


--
-- Name: course_test_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX course_test_course_id ON public."CourseTest" USING btree ("courseId");


--
-- Name: course_test_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX course_test_test_id ON public."CourseTest" USING btree ("testId");


--
-- Name: customerissueunresolvedflashcard; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX customerissueunresolvedflashcard ON public."CustomerIssue" USING btree ("userId", "flashCardId") WHERE (resolved = false);


--
-- Name: difficultyLevel10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "difficultyLevel10" ON public."QuestionAnalytics25" USING btree ("difficultyLevel");


--
-- Name: doubt_admins_doubtId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "doubt_admins_doubtId_idx" ON public.doubt_admins USING btree ("doubtId");


--
-- Name: drupal_2WkW2rDHKTAuZ0sp2gS_oVSlKUSTjzLA_o5lQ2yjSxk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_2WkW2rDHKTAuZ0sp2gS_oVSlKUSTjzLA_o5lQ2yjSxk_idx" ON public.drupal_taxonomy_term_data USING btree (vid);


--
-- Name: drupal_2iYXGShMfy6U1Md5x8P7BDx7JT2s_fAFotjvdqBFICo_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_2iYXGShMfy6U1Md5x8P7BDx7JT2s_fAFotjvdqBFICo_idx" ON public.drupal_shortcut_field_data USING btree (shortcut_set);


--
-- Name: drupal_4R5k8gb9lS4_u1dM08ReAxIB2YvM5QR5zT1ksoHdKk4_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_4R5k8gb9lS4_u1dM08ReAxIB2YvM5QR5zT1ksoHdKk4_idx" ON public.drupal_comment_field_data USING btree (comment_type);


--
-- Name: drupal_5HDxA7KulvPEudfRd4yoKYsVXCL3IsJDzm6jrAc3SsQ_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_5HDxA7KulvPEudfRd4yoKYsVXCL3IsJDzm6jrAc3SsQ_idx" ON public.drupal_block_content_field_data USING btree (id, default_langcode, langcode);


--
-- Name: drupal_5xsyULeQe8iYqpcLv3TcOnK70Rxw6aYy9pwLwmbQ5dg_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_5xsyULeQe8iYqpcLv3TcOnK70Rxw6aYy9pwLwmbQ5dg_idx" ON public.drupal_shortcut_field_data USING btree (id, default_langcode, langcode);


--
-- Name: drupal_Agu3DzIkGoLovnZlRkbtObsyRX5Aoc111NlGGhQnMrY_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_Agu3DzIkGoLovnZlRkbtObsyRX5Aoc111NlGGhQnMrY_idx" ON public.drupal_taxonomy_term_field_data USING btree (tid, default_langcode, langcode);


--
-- Name: drupal_EENQTA2lrY_Noin5yUqztBKLF5RCNJc979dqTzskLAM_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_EENQTA2lrY_Noin5yUqztBKLF5RCNJc979dqTzskLAM_idx" ON public.drupal_taxonomy_term_field_revision USING btree (description__format);


--
-- Name: drupal_ItFcO8Z4TtkHPw9aYqHOh_SQ9lQUPH2_GBMGsgb9e6E_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_ItFcO8Z4TtkHPw9aYqHOh_SQ9lQUPH2_GBMGsgb9e6E_idx" ON public.drupal_users_field_data USING btree (uid, default_langcode, langcode);


--
-- Name: drupal_OONi8dt_er_IJWEP2yizs4WKuNQT3kRUwlDThOOQMNE_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_OONi8dt_er_IJWEP2yizs4WKuNQT3kRUwlDThOOQMNE_idx" ON public.drupal_taxonomy_term_field_data USING btree (revision_id);


--
-- Name: drupal_QnV_yx12IV6LUDK8fiqQScOLltRLWh6lj73Z_u1PXWY_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_QnV_yx12IV6LUDK8fiqQScOLltRLWh6lj73Z_u1PXWY_idx" ON public.drupal_menu_link_content_field_revision USING btree (substr((link__uri)::text, 1, 30));


--
-- Name: drupal_RJguZGrY1lqakWsNPDkV5fpfIdfmXzgP6r5jnmFiSyQ_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_RJguZGrY1lqakWsNPDkV5fpfIdfmXzgP6r5jnmFiSyQ_idx" ON public.drupal_taxonomy_term_field_revision USING btree (tid, default_langcode, langcode);


--
-- Name: drupal_Sqc70zqbkgRTBjonZwn_XDEMHS44PjMq7OAm316sMew_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_Sqc70zqbkgRTBjonZwn_XDEMHS44PjMq7OAm316sMew_idx" ON public.drupal_taxonomy_term_revision USING btree (revision_user);


--
-- Name: drupal_Txnsmz4PXYNvliwMqnitosP85A_C_OZPIbzcp867Wg4_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_Txnsmz4PXYNvliwMqnitosP85A_C_OZPIbzcp867Wg4_idx" ON public.drupal_menu_link_content_data USING btree (enabled, bundle, id);


--
-- Name: drupal_WDtmXUpoI3tQcnQT4tJyUWZVj2f_CtQ5QFGHlNnWq7o_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_WDtmXUpoI3tQcnQT4tJyUWZVj2f_CtQ5QFGHlNnWq7o_idx" ON public.drupal_node_field_revision USING btree (nid, default_langcode, langcode);


--
-- Name: drupal_XkAl6i7KGA5LbzjrrqKjIvDr3SJkT2GIfjqD26Cjt9I_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_XkAl6i7KGA5LbzjrrqKjIvDr3SJkT2GIfjqD26Cjt9I_idx" ON public.drupal_menu_link_content_data USING btree (id, default_langcode, langcode);


--
-- Name: drupal_batch__token__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_batch__token__idx ON public.drupal_batch USING btree (token);


--
-- Name: drupal_block_content__block_content_field__type__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_block_content__block_content_field__type__target_id__idx ON public.drupal_block_content USING btree (type);


--
-- Name: drupal_block_content__body__body_format__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_block_content__body__body_format__idx ON public.drupal_block_content__body USING btree (body_format);


--
-- Name: drupal_block_content__body__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_block_content__body__bundle__idx ON public.drupal_block_content__body USING btree (bundle);


--
-- Name: drupal_block_content__body__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_block_content__body__revision_id__idx ON public.drupal_block_content__body USING btree (revision_id);


--
-- Name: drupal_block_content_revision__block_content__id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_block_content_revision__block_content__id__idx ON public.drupal_block_content_revision USING btree (id);


--
-- Name: drupal_block_content_revision__body__body_format__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_block_content_revision__body__body_format__idx ON public.drupal_block_content_revision__body USING btree (body_format);


--
-- Name: drupal_block_content_revision__body__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_block_content_revision__body__bundle__idx ON public.drupal_block_content_revision__body USING btree (bundle);


--
-- Name: drupal_block_content_revision__body__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_block_content_revision__body__revision_id__idx ON public.drupal_block_content_revision__body USING btree (revision_id);


--
-- Name: drupal_cVSMadGF_0hxpr1v27sC8JIBiKf0wZKWoxVY_kIYg5Y_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_cVSMadGF_0hxpr1v27sC8JIBiKf0wZKWoxVY_kIYg5Y_idx" ON public.drupal_comment_field_data USING btree (cid, default_langcode, langcode);


--
-- Name: drupal_cache_bootstrap__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_bootstrap__created__idx ON public.drupal_cache_bootstrap USING btree (created);


--
-- Name: drupal_cache_bootstrap__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_bootstrap__expire__idx ON public.drupal_cache_bootstrap USING btree (expire);


--
-- Name: drupal_cache_config__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_config__created__idx ON public.drupal_cache_config USING btree (created);


--
-- Name: drupal_cache_config__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_config__expire__idx ON public.drupal_cache_config USING btree (expire);


--
-- Name: drupal_cache_container__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_container__created__idx ON public.drupal_cache_container USING btree (created);


--
-- Name: drupal_cache_container__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_container__expire__idx ON public.drupal_cache_container USING btree (expire);


--
-- Name: drupal_cache_data__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_data__created__idx ON public.drupal_cache_data USING btree (created);


--
-- Name: drupal_cache_data__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_data__expire__idx ON public.drupal_cache_data USING btree (expire);


--
-- Name: drupal_cache_default__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_default__created__idx ON public.drupal_cache_default USING btree (created);


--
-- Name: drupal_cache_default__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_default__expire__idx ON public.drupal_cache_default USING btree (expire);


--
-- Name: drupal_cache_discovery__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_discovery__created__idx ON public.drupal_cache_discovery USING btree (created);


--
-- Name: drupal_cache_discovery__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_discovery__expire__idx ON public.drupal_cache_discovery USING btree (expire);


--
-- Name: drupal_cache_dynamic_page_cache__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_dynamic_page_cache__created__idx ON public.drupal_cache_dynamic_page_cache USING btree (created);


--
-- Name: drupal_cache_dynamic_page_cache__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_dynamic_page_cache__expire__idx ON public.drupal_cache_dynamic_page_cache USING btree (expire);


--
-- Name: drupal_cache_entity__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_entity__created__idx ON public.drupal_cache_entity USING btree (created);


--
-- Name: drupal_cache_entity__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_entity__expire__idx ON public.drupal_cache_entity USING btree (expire);


--
-- Name: drupal_cache_menu__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_menu__created__idx ON public.drupal_cache_menu USING btree (created);


--
-- Name: drupal_cache_menu__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_menu__expire__idx ON public.drupal_cache_menu USING btree (expire);


--
-- Name: drupal_cache_page__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_page__created__idx ON public.drupal_cache_page USING btree (created);


--
-- Name: drupal_cache_page__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_page__expire__idx ON public.drupal_cache_page USING btree (expire);


--
-- Name: drupal_cache_render__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_render__created__idx ON public.drupal_cache_render USING btree (created);


--
-- Name: drupal_cache_render__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_render__expire__idx ON public.drupal_cache_render USING btree (expire);


--
-- Name: drupal_cache_toolbar__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_toolbar__created__idx ON public.drupal_cache_toolbar USING btree (created);


--
-- Name: drupal_cache_toolbar__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_cache_toolbar__expire__idx ON public.drupal_cache_toolbar USING btree (expire);


--
-- Name: drupal_comment__comment_body__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment__comment_body__bundle__idx ON public.drupal_comment__comment_body USING btree (bundle);


--
-- Name: drupal_comment__comment_body__comment_body_format__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment__comment_body__comment_body_format__idx ON public.drupal_comment__comment_body USING btree (comment_body_format);


--
-- Name: drupal_comment__comment_body__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment__comment_body__revision_id__idx ON public.drupal_comment__comment_body USING btree (revision_id);


--
-- Name: drupal_comment__comment_field__comment_type__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment__comment_field__comment_type__target_id__idx ON public.drupal_comment USING btree (comment_type);


--
-- Name: drupal_comment_entity_statistics__comment_count__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_entity_statistics__comment_count__idx ON public.drupal_comment_entity_statistics USING btree (comment_count);


--
-- Name: drupal_comment_entity_statistics__last_comment_timestamp__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_entity_statistics__last_comment_timestamp__idx ON public.drupal_comment_entity_statistics USING btree (last_comment_timestamp);


--
-- Name: drupal_comment_entity_statistics__last_comment_uid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_entity_statistics__last_comment_uid__idx ON public.drupal_comment_entity_statistics USING btree (last_comment_uid);


--
-- Name: drupal_comment_field_data__comment__entity_langcode__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_field_data__comment__entity_langcode__idx ON public.drupal_comment_field_data USING btree (entity_id, entity_type, comment_type, default_langcode);


--
-- Name: drupal_comment_field_data__comment__num_new__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_field_data__comment__num_new__idx ON public.drupal_comment_field_data USING btree (entity_id, entity_type, comment_type, status, created, cid, thread);


--
-- Name: drupal_comment_field_data__comment__status_comment_type__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_field_data__comment__status_comment_type__idx ON public.drupal_comment_field_data USING btree (status, comment_type, cid);


--
-- Name: drupal_comment_field_data__comment__status_pid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_field_data__comment__status_pid__idx ON public.drupal_comment_field_data USING btree (pid, status);


--
-- Name: drupal_comment_field_data__comment_field__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_field_data__comment_field__created__idx ON public.drupal_comment_field_data USING btree (created);


--
-- Name: drupal_comment_field_data__comment_field__uid__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_comment_field_data__comment_field__uid__target_id__idx ON public.drupal_comment_field_data USING btree (uid);


--
-- Name: drupal_file_managed__file_field__changed__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_file_managed__file_field__changed__idx ON public.drupal_file_managed USING btree (changed);


--
-- Name: drupal_file_managed__file_field__status__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_file_managed__file_field__status__idx ON public.drupal_file_managed USING btree (status);


--
-- Name: drupal_file_managed__file_field__uid__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_file_managed__file_field__uid__target_id__idx ON public.drupal_file_managed USING btree (uid);


--
-- Name: drupal_file_managed__file_field__uri__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_file_managed__file_field__uri__idx ON public.drupal_file_managed USING btree (uri);


--
-- Name: drupal_file_usage__fid_count__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_file_usage__fid_count__idx ON public.drupal_file_usage USING btree (fid, count);


--
-- Name: drupal_file_usage__fid_module__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_file_usage__fid_module__idx ON public.drupal_file_usage USING btree (fid, module);


--
-- Name: drupal_file_usage__type_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_file_usage__type_id__idx ON public.drupal_file_usage USING btree (type, id);


--
-- Name: drupal_h5p_content__h5p_library__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_h5p_content__h5p_library__idx ON public.drupal_h5p_content USING btree (library_id);


--
-- Name: drupal_h5p_content_libraries__weight__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_h5p_content_libraries__weight__idx ON public.drupal_h5p_content_libraries USING btree (weight);


--
-- Name: drupal_h5p_events__created_at__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_h5p_events__created_at__idx ON public.drupal_h5p_events USING btree (created_at);


--
-- Name: drupal_h5p_libraries__library__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_h5p_libraries__library__idx ON public.drupal_h5p_libraries USING btree (machine_name, major_version, minor_version);


--
-- Name: drupal_h5p_libraries__title__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_h5p_libraries__title__idx ON public.drupal_h5p_libraries USING btree (title);


--
-- Name: drupal_h5p_libraries_hub_cache__machine_name__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_h5p_libraries_hub_cache__machine_name__idx ON public.drupal_h5p_libraries_hub_cache USING btree (machine_name);


--
-- Name: drupal_history__nid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_history__nid__idx ON public.drupal_history USING btree (nid);


--
-- Name: drupal_i0Re9DsmoAaiXcm02u2v0Jn2f47jG6lHSdYevPDo1RQ_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_i0Re9DsmoAaiXcm02u2v0Jn2f47jG6lHSdYevPDo1RQ_idx" ON public.drupal_block_content_field_data USING btree (type);


--
-- Name: drupal_jQo4tQ0QnB5zlKZgqIxF3pnmufQhXRmPhGrj9JwlsTw_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_jQo4tQ0QnB5zlKZgqIxF3pnmufQhXRmPhGrj9JwlsTw_idx" ON public.drupal_menu_link_content_data USING btree (revision_id);


--
-- Name: drupal_japlpTlVFdkxFOCqEzOf_I1XRt2rDXKPwU7kU2OoJDg_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_japlpTlVFdkxFOCqEzOf_I1XRt2rDXKPwU7kU2OoJDg_idx" ON public.drupal_block_content_field_revision USING btree (id, default_langcode, langcode);


--
-- Name: drupal_key_value_expire__all__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_key_value_expire__all__idx ON public.drupal_key_value_expire USING btree (name, collection, expire);


--
-- Name: drupal_key_value_expire__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_key_value_expire__expire__idx ON public.drupal_key_value_expire USING btree (expire);


--
-- Name: drupal_l49aMQ_MdQ3FDWdekL6JfXtLDM9M3USLnG3Zg_T5QrI_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_l49aMQ_MdQ3FDWdekL6JfXtLDM9M3USLnG3Zg_T5QrI_idx" ON public.drupal_menu_link_content_data USING btree (substr((link__uri)::text, 1, 30));


--
-- Name: drupal_lzXQShkPKTs_XiR9LgOH4mhN5_TmIz6ZUUu04OxYf3I_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_lzXQShkPKTs_XiR9LgOH4mhN5_TmIz6ZUUu04OxYf3I_idx" ON public.drupal_block_content_revision USING btree (revision_user);


--
-- Name: drupal_menu_link_content_revision__menu_link_content__id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_menu_link_content_revision__menu_link_content__id__idx ON public.drupal_menu_link_content_revision USING btree (id);


--
-- Name: drupal_menu_tree__menu_parent_expand_child__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_menu_tree__menu_parent_expand_child__idx ON public.drupal_menu_tree USING btree (menu_name, expanded, has_children, substr((parent)::text, 1, 16));


--
-- Name: drupal_menu_tree__menu_parents__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_menu_tree__menu_parents__idx ON public.drupal_menu_tree USING btree (menu_name, p1, p2, p3, p4, p5, p6, p7, p8, p9);


--
-- Name: drupal_menu_tree__route_values__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_menu_tree__route_values__idx ON public.drupal_menu_tree USING btree (substr((route_name)::text, 1, 32), substr((route_param_key)::text, 1, 16));


--
-- Name: drupal_mg0CEMgG7XU4Bn2RxXTtbyYyjLJ5VOTZXKidWpIMBr8_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_mg0CEMgG7XU4Bn2RxXTtbyYyjLJ5VOTZXKidWpIMBr8_idx" ON public.drupal_block_content_field_data USING btree (status, type, id);


--
-- Name: drupal_node__body__body_format__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__body__body_format__idx ON public.drupal_node__body USING btree (body_format);


--
-- Name: drupal_node__body__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__body__bundle__idx ON public.drupal_node__body USING btree (bundle);


--
-- Name: drupal_node__body__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__body__revision_id__idx ON public.drupal_node__body USING btree (revision_id);


--
-- Name: drupal_node__comment__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__comment__bundle__idx ON public.drupal_node__comment USING btree (bundle);


--
-- Name: drupal_node__comment__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__comment__revision_id__idx ON public.drupal_node__comment USING btree (revision_id);


--
-- Name: drupal_node__field_h5p__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_h5p__bundle__idx ON public.drupal_node__field_h5p USING btree (bundle);


--
-- Name: drupal_node__field_h5p__field_h5p_h5p_content_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_h5p__field_h5p_h5p_content_id__idx ON public.drupal_node__field_h5p USING btree (field_h5p_h5p_content_id);


--
-- Name: drupal_node__field_h5p__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_h5p__revision_id__idx ON public.drupal_node__field_h5p USING btree (revision_id);


--
-- Name: drupal_node__field_image__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_image__bundle__idx ON public.drupal_node__field_image USING btree (bundle);


--
-- Name: drupal_node__field_image__field_image_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_image__field_image_target_id__idx ON public.drupal_node__field_image USING btree (field_image_target_id);


--
-- Name: drupal_node__field_image__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_image__revision_id__idx ON public.drupal_node__field_image USING btree (revision_id);


--
-- Name: drupal_node__field_tags__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_tags__bundle__idx ON public.drupal_node__field_tags USING btree (bundle);


--
-- Name: drupal_node__field_tags__field_tags_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_tags__field_tags_target_id__idx ON public.drupal_node__field_tags USING btree (field_tags_target_id);


--
-- Name: drupal_node__field_tags__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__field_tags__revision_id__idx ON public.drupal_node__field_tags USING btree (revision_id);


--
-- Name: drupal_node__node_field__type__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node__node_field__type__target_id__idx ON public.drupal_node USING btree (type);


--
-- Name: drupal_node_field_data__node__frontpage__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_data__node__frontpage__idx ON public.drupal_node_field_data USING btree (promote, status, sticky, created);


--
-- Name: drupal_node_field_data__node__status_type__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_data__node__status_type__idx ON public.drupal_node_field_data USING btree (status, type, nid);


--
-- Name: drupal_node_field_data__node__title_type__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_data__node__title_type__idx ON public.drupal_node_field_data USING btree (title, substr((type)::text, 1, 4));


--
-- Name: drupal_node_field_data__node__vid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_data__node__vid__idx ON public.drupal_node_field_data USING btree (vid);


--
-- Name: drupal_node_field_data__node_field__changed__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_data__node_field__changed__idx ON public.drupal_node_field_data USING btree (changed);


--
-- Name: drupal_node_field_data__node_field__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_data__node_field__created__idx ON public.drupal_node_field_data USING btree (created);


--
-- Name: drupal_node_field_data__node_field__type__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_data__node_field__type__target_id__idx ON public.drupal_node_field_data USING btree (type);


--
-- Name: drupal_node_field_data__node_field__uid__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_data__node_field__uid__target_id__idx ON public.drupal_node_field_data USING btree (uid);


--
-- Name: drupal_node_field_revision__node_field__uid__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_field_revision__node_field__uid__target_id__idx ON public.drupal_node_field_revision USING btree (uid);


--
-- Name: drupal_node_revision__body__body_format__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__body__body_format__idx ON public.drupal_node_revision__body USING btree (body_format);


--
-- Name: drupal_node_revision__body__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__body__bundle__idx ON public.drupal_node_revision__body USING btree (bundle);


--
-- Name: drupal_node_revision__body__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__body__revision_id__idx ON public.drupal_node_revision__body USING btree (revision_id);


--
-- Name: drupal_node_revision__comment__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__comment__bundle__idx ON public.drupal_node_revision__comment USING btree (bundle);


--
-- Name: drupal_node_revision__comment__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__comment__revision_id__idx ON public.drupal_node_revision__comment USING btree (revision_id);


--
-- Name: drupal_node_revision__field_h5p__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_h5p__bundle__idx ON public.drupal_node_revision__field_h5p USING btree (bundle);


--
-- Name: drupal_node_revision__field_h5p__field_h5p_h5p_content_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_h5p__field_h5p_h5p_content_id__idx ON public.drupal_node_revision__field_h5p USING btree (field_h5p_h5p_content_id);


--
-- Name: drupal_node_revision__field_h5p__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_h5p__revision_id__idx ON public.drupal_node_revision__field_h5p USING btree (revision_id);


--
-- Name: drupal_node_revision__field_image__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_image__bundle__idx ON public.drupal_node_revision__field_image USING btree (bundle);


--
-- Name: drupal_node_revision__field_image__field_image_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_image__field_image_target_id__idx ON public.drupal_node_revision__field_image USING btree (field_image_target_id);


--
-- Name: drupal_node_revision__field_image__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_image__revision_id__idx ON public.drupal_node_revision__field_image USING btree (revision_id);


--
-- Name: drupal_node_revision__field_tags__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_tags__bundle__idx ON public.drupal_node_revision__field_tags USING btree (bundle);


--
-- Name: drupal_node_revision__field_tags__field_tags_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_tags__field_tags_target_id__idx ON public.drupal_node_revision__field_tags USING btree (field_tags_target_id);


--
-- Name: drupal_node_revision__field_tags__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__field_tags__revision_id__idx ON public.drupal_node_revision__field_tags USING btree (revision_id);


--
-- Name: drupal_node_revision__node__nid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__node__nid__idx ON public.drupal_node_revision USING btree (nid);


--
-- Name: drupal_node_revision__node_field__langcode__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__node_field__langcode__idx ON public.drupal_node_revision USING btree (langcode);


--
-- Name: drupal_node_revision__node_field__revision_uid__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_node_revision__node_field__revision_uid__target_id__idx ON public.drupal_node_revision USING btree (revision_uid);


--
-- Name: drupal_oBgqUhimP4lLm603LfPC5jISBFm6_Xc0FDyZkgE1aBg_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_oBgqUhimP4lLm603LfPC5jISBFm6_Xc0FDyZkgE1aBg_idx" ON public.drupal_node_field_data USING btree (nid, default_langcode, langcode);


--
-- Name: drupal_path_alias__path_alias__alias_langcode_id_status__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_path_alias__path_alias__alias_langcode_id_status__idx ON public.drupal_path_alias USING btree (alias, langcode, id, status);


--
-- Name: drupal_path_alias__path_alias__path_langcode_id_status__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_path_alias__path_alias__path_langcode_id_status__idx ON public.drupal_path_alias USING btree (path, langcode, id, status);


--
-- Name: drupal_path_alias__path_alias__status__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_path_alias__path_alias__status__idx ON public.drupal_path_alias USING btree (status, id);


--
-- Name: drupal_path_alias_revision__path_alias__id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_path_alias_revision__path_alias__id__idx ON public.drupal_path_alias_revision USING btree (id);


--
-- Name: drupal_qUMWUKjUQm2iEerDmqhNAn9AGhMDVpu9Ic0owiNvk6g_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_qUMWUKjUQm2iEerDmqhNAn9AGhMDVpu9Ic0owiNvk6g_idx" ON public.drupal_block_content_field_data USING btree (revision_id);


--
-- Name: drupal_queue__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_queue__expire__idx ON public.drupal_queue USING btree (expire);


--
-- Name: drupal_queue__name_created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_queue__name_created__idx ON public.drupal_queue USING btree (name, created);


--
-- Name: drupal_router__pattern_outline_parts__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_router__pattern_outline_parts__idx ON public.drupal_router USING btree (pattern_outline, number_parts);


--
-- Name: drupal_s3fs_file__timestamp__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_s3fs_file__timestamp__idx ON public.drupal_s3fs_file USING btree ("timestamp");


--
-- Name: drupal_search_index__sid_type__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_search_index__sid_type__idx ON public.drupal_search_index USING btree (sid, langcode, type);


--
-- Name: drupal_semaphore__expire__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_semaphore__expire__idx ON public.drupal_semaphore USING btree (expire);


--
-- Name: drupal_semaphore__value__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_semaphore__value__idx ON public.drupal_semaphore USING btree (value);


--
-- Name: drupal_sessions__timestamp__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_sessions__timestamp__idx ON public.drupal_sessions USING btree ("timestamp");


--
-- Name: drupal_sessions__uid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_sessions__uid__idx ON public.drupal_sessions USING btree (uid);


--
-- Name: drupal_shortcut__shortcut_field__shortcut_set__target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_shortcut__shortcut_field__shortcut_set__target_id__idx ON public.drupal_shortcut USING btree (shortcut_set);


--
-- Name: drupal_shortcut_field_data__shortcut_field__link__uri__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_shortcut_field_data__shortcut_field__link__uri__idx ON public.drupal_shortcut_field_data USING btree (substr((link__uri)::text, 1, 30));


--
-- Name: drupal_shortcut_set_users__set_name__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_shortcut_set_users__set_name__idx ON public.drupal_shortcut_set_users USING btree (set_name);


--
-- Name: drupal_sp0KOjWoGZ3w3gvNpK_LrsSZT3Vd1wbELkfIg7d0434_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_sp0KOjWoGZ3w3gvNpK_LrsSZT3Vd1wbELkfIg7d0434_idx" ON public.drupal_menu_link_content_revision USING btree (revision_user);


--
-- Name: drupal_taxonomy_index__term_node__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_index__term_node__idx ON public.drupal_taxonomy_index USING btree (tid, status, sticky, created);


--
-- Name: drupal_taxonomy_term__parent__bundle_delta_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term__parent__bundle_delta_target_id__idx ON public.drupal_taxonomy_term__parent USING btree (bundle, delta, parent_target_id);


--
-- Name: drupal_taxonomy_term__parent__parent_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term__parent__parent_target_id__idx ON public.drupal_taxonomy_term__parent USING btree (parent_target_id);


--
-- Name: drupal_taxonomy_term__parent__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term__parent__revision_id__idx ON public.drupal_taxonomy_term__parent USING btree (revision_id);


--
-- Name: drupal_taxonomy_term_field_data__taxonomy_term__status_vid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term_field_data__taxonomy_term__status_vid__idx ON public.drupal_taxonomy_term_field_data USING btree (status, vid, tid);


--
-- Name: drupal_taxonomy_term_field_data__taxonomy_term__tree__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term_field_data__taxonomy_term__tree__idx ON public.drupal_taxonomy_term_field_data USING btree (vid, weight, name);


--
-- Name: drupal_taxonomy_term_field_data__taxonomy_term__vid_name__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term_field_data__taxonomy_term__vid_name__idx ON public.drupal_taxonomy_term_field_data USING btree (vid, name);


--
-- Name: drupal_taxonomy_term_field_data__taxonomy_term_field__name__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term_field_data__taxonomy_term_field__name__idx ON public.drupal_taxonomy_term_field_data USING btree (name);


--
-- Name: drupal_taxonomy_term_revision__parent__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term_revision__parent__bundle__idx ON public.drupal_taxonomy_term_revision__parent USING btree (bundle);


--
-- Name: drupal_taxonomy_term_revision__parent__parent_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term_revision__parent__parent_target_id__idx ON public.drupal_taxonomy_term_revision__parent USING btree (parent_target_id);


--
-- Name: drupal_taxonomy_term_revision__parent__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term_revision__parent__revision_id__idx ON public.drupal_taxonomy_term_revision__parent USING btree (revision_id);


--
-- Name: drupal_taxonomy_term_revision__taxonomy_term__tid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_taxonomy_term_revision__taxonomy_term__tid__idx ON public.drupal_taxonomy_term_revision USING btree (tid);


--
-- Name: drupal_user__roles__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_user__roles__bundle__idx ON public.drupal_user__roles USING btree (bundle);


--
-- Name: drupal_user__roles__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_user__roles__revision_id__idx ON public.drupal_user__roles USING btree (revision_id);


--
-- Name: drupal_user__roles__roles_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_user__roles__roles_target_id__idx ON public.drupal_user__roles USING btree (roles_target_id);


--
-- Name: drupal_user__user_picture__bundle__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_user__user_picture__bundle__idx ON public.drupal_user__user_picture USING btree (bundle);


--
-- Name: drupal_user__user_picture__revision_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_user__user_picture__revision_id__idx ON public.drupal_user__user_picture USING btree (revision_id);


--
-- Name: drupal_user__user_picture__user_picture_target_id__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_user__user_picture__user_picture_target_id__idx ON public.drupal_user__user_picture USING btree (user_picture_target_id);


--
-- Name: drupal_users_data__module__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_users_data__module__idx ON public.drupal_users_data USING btree (module);


--
-- Name: drupal_users_data__name__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_users_data__name__idx ON public.drupal_users_data USING btree (name);


--
-- Name: drupal_users_field_data__user_field__access__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_users_field_data__user_field__access__idx ON public.drupal_users_field_data USING btree (access);


--
-- Name: drupal_users_field_data__user_field__created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_users_field_data__user_field__created__idx ON public.drupal_users_field_data USING btree (created);


--
-- Name: drupal_users_field_data__user_field__mail__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_users_field_data__user_field__mail__idx ON public.drupal_users_field_data USING btree (mail);


--
-- Name: drupal_watchdog__severity__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_watchdog__severity__idx ON public.drupal_watchdog USING btree (severity);


--
-- Name: drupal_watchdog__type__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_watchdog__type__idx ON public.drupal_watchdog USING btree (type);


--
-- Name: drupal_watchdog__uid__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX drupal_watchdog__uid__idx ON public.drupal_watchdog USING btree (uid);


--
-- Name: drupal_zEbDWUZt6MxU7ude3NMzflCrVl6J1GoH7K0ojqLsx3Y_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "drupal_zEbDWUZt6MxU7ude3NMzflCrVl6J1GoH7K0ojqLsx3Y_idx" ON public.drupal_menu_link_content_field_revision USING btree (id, default_langcode, langcode);


--
-- Name: inFullCourse10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "inFullCourse10" ON public."QuestionAnalytics25" USING btree ("inFullCourse");


--
-- Name: incorrectReason1Count10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "incorrectReason1Count10" ON public."QuestionAnalytics25" USING btree ("incorrectReason1Count");


--
-- Name: incorrectReason2Count10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "incorrectReason2Count10" ON public."QuestionAnalytics25" USING btree ("incorrectReason2Count");


--
-- Name: incorrectReason3Count10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "incorrectReason3Count10" ON public."QuestionAnalytics25" USING btree ("incorrectReason3Count");


--
-- Name: index_Glossary_on_word; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_Glossary_on_word" ON public."Glossary" USING btree (word);


--
-- Name: index_ScheduleItemAsset_on_ScheduleItem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "index_ScheduleItemAsset_on_ScheduleItem_id" ON public."ScheduleItemAsset" USING btree ("ScheduleItem_id");


--
-- Name: index_TestQuestion_on_testId_and_questionId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_TestQuestion_on_testId_and_questionId" ON public."TestQuestion" USING btree ("testId", "questionId");


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON public.admin_users USING btree (reset_password_token);


--
-- Name: index_admin_users_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_users_on_role ON public.admin_users USING btree (role);


--
-- Name: index_dcd_on_dcc_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dcd_on_dcc_id ON public.doubt_chat_doubts USING btree (doubt_chat_channel_id);


--
-- Name: index_dcd_on_dcu_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dcd_on_dcu_id ON public.doubt_chat_doubts USING btree (doubt_chat_user_id);


--
-- Name: index_dcda_on_dcd_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dcda_on_dcd_id ON public.doubt_chat_doubt_answers USING btree (doubt_chat_doubt_id);


--
-- Name: index_dcda_on_dcu_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dcda_on_dcu_id ON public.doubt_chat_doubt_answers USING btree (doubt_chat_user_id);


--
-- Name: index_doubt_admins_on_admin_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_doubt_admins_on_admin_user_id ON public.doubt_admins USING btree (admin_user_id);


--
-- Name: index_doubt_admins_on_doubtId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_doubt_admins_on_doubtId" ON public.doubt_admins USING btree ("doubtId");


--
-- Name: index_doubt_chat_doubt_answers_on_ancestry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_doubt_chat_doubt_answers_on_ancestry ON public.doubt_chat_doubt_answers USING btree (ancestry);


--
-- Name: index_student_coaches_on_studentId_and_coachId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_student_coaches_on_studentId_and_coachId" ON public.student_coaches USING btree ("studentId", "coachId");


--
-- Name: index_user_actions_on_userId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_user_actions_on_userId" ON public.user_actions USING btree ("userId");


--
-- Name: index_version_associations_on_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_associations_on_foreign_key ON public.version_associations USING btree (foreign_key_name, foreign_key_id, foreign_type);


--
-- Name: index_version_associations_on_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_associations_on_version_id ON public.version_associations USING btree (version_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_versions_on_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_transaction_id ON public.versions USING btree (transaction_id);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_votable_id_and_votable_type_and_vote_scope ON public.votes USING btree (votable_id, votable_type, vote_scope);


--
-- Name: index_votes_on_votable_type_and_votable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_votable_type_and_votable_id ON public.votes USING btree (votable_type, votable_id);


--
-- Name: index_votes_on_voter_id_and_voter_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_voter_id_and_voter_type_and_vote_scope ON public.votes USING btree (voter_id, voter_type, vote_scope);


--
-- Name: index_votes_on_voter_type_and_voter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_voter_type_and_voter_id ON public.votes USING btree (voter_type, voter_id);


--
-- Name: index_work_logs_on_date_and_admin_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_work_logs_on_date_and_admin_user_id ON public.work_logs USING btree (date, admin_user_id);


--
-- Name: motivation_message_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX motivation_message_unique ON public."Motivation" USING btree (message);


--
-- Name: ncert_chapter_question_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ncert_chapter_question_chapter_id ON public."NcertChapterQuestion" USING btree ("chapterId");


--
-- Name: ncert_chapter_question_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ncert_chapter_question_question_id ON public."NcertChapterQuestion" USING btree ("questionId");


--
-- Name: ncert_sentence_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ncert_sentence_idx ON public."NcertSentence" USING btree (sentence);


--
-- Name: notification_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_user_id ON public."Notification" USING btree ("userId");


--
-- Name: partial_idx_answer_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partial_idx_answer_created_at ON public."Answer" USING btree ("createdAt") WHERE ("createdAt" >= '2021-04-01 00:00:00+00'::timestamp with time zone);


--
-- Name: partial_idx_answer_created_at_1_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partial_idx_answer_created_at_1_month ON public."Answer" USING btree ("createdAt") WHERE ("createdAt" >= '2021-05-11 00:00:00+00'::timestamp with time zone);


--
-- Name: partial_idx_answer_created_at_2020; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partial_idx_answer_created_at_2020 ON public."Answer" USING btree ("createdAt") WHERE (("createdAt" >= '2020-04-01 00:00:00+00'::timestamp with time zone) AND ("createdAt" <= '2020-06-30 00:00:00+00'::timestamp with time zone));


--
-- Name: question_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX question_deleted ON public."Question" USING btree (deleted);


--
-- Name: question_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX question_gin_idx ON public."Question" USING gin (question public.gin_trgm_ops);


--
-- Name: question_subTopic_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "question_subTopic_question_id" ON public."QuestionSubTopic" USING btree ("questionId");


--
-- Name: question_subTopic_subTopic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "question_subTopic_subTopic_id" ON public."QuestionSubTopic" USING btree ("subTopicId");


--
-- Name: s_e_o_data_owner_id_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX s_e_o_data_owner_id_owner_type ON public."SEOData" USING btree ("ownerId", "ownerType");


--
-- Name: scheduled_task_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_task_course_id ON public."ScheduledTask" USING btree ("courseId");


--
-- Name: scheduled_task_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_task_expired_at ON public."ScheduledTask" USING btree ("expiredAt");


--
-- Name: scheduled_task_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_task_scheduled_at ON public."ScheduledTask" USING btree ("scheduledAt");


--
-- Name: scheduled_task_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_task_task_id ON public."ScheduledTask" USING btree ("taskId");


--
-- Name: scheduled_task_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_task_year ON public."ScheduledTask" USING btree (year);


--
-- Name: single_applicable_course_offer_constraint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX single_applicable_course_offer_constraint ON public."CourseOffer" USING btree ("courseId", email, "offerExpiryAt", title);


--
-- Name: studentnoteuniquencerthighlight; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX studentnoteuniquencerthighlight ON public."StudentNote" USING btree ("userId", "noteId", details);


--
-- Name: subject_chapter_chapter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subject_chapter_chapter_id ON public."SubjectChapter" USING btree ("chapterId");


--
-- Name: subject_chapter_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subject_chapter_deleted ON public."SubjectChapter" USING btree (deleted);


--
-- Name: subject_chapter_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subject_chapter_subject_id ON public."SubjectChapter" USING btree ("subjectId");


--
-- Name: subject_leader_board_subject_id3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subject_leader_board_subject_id3 ON public."SubjectLeaderBoard" USING btree ("subjectId");


--
-- Name: subject_leader_board_user_id_subject_id3; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subject_leader_board_user_id_subject_id3 ON public."SubjectLeaderBoard" USING btree ("subjectId", "userId");


--
-- Name: tagExist10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "tagExist10" ON public."QuestionAnalytics25" USING btree ("tagExist");


--
-- Name: task_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_course_id ON public."Task" USING btree ("courseId");


--
-- Name: task_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_expired_at ON public."Task" USING btree ("expiredAt");


--
-- Name: task_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_parent_id ON public."Task" USING btree ("parentId");


--
-- Name: task_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_scheduled_at ON public."Task" USING btree ("scheduledAt");


--
-- Name: task_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_year ON public."Task" USING btree (year);


--
-- Name: testAttempt_postmartem_testAttempt_id_user_id_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "testAttempt_postmartem_testAttempt_id_user_id_question_id" ON public."TestAttemptPostmartem" USING btree ("testAttemptId", "userId", "questionId");


--
-- Name: test_attempt_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_attempt_test_id ON public."TestAttempt" USING btree ("testId");


--
-- Name: test_attempt_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_attempt_user_id ON public."TestAttempt" USING btree ("userId");


--
-- Name: test_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_creator_id ON public."Test" USING btree ("creatorId");


--
-- Name: test_leader_board_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_leader_board_test_id ON public."TestLeaderBoard" USING btree ("testId");


--
-- Name: test_leader_board_user_id_test_attempt_id_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX test_leader_board_user_id_test_attempt_id_test_id ON public."TestLeaderBoard" USING btree ("userId", "testId", "testAttemptId");


--
-- Name: test_leader_board_user_id_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_leader_board_user_id_test_id ON public."TestLeaderBoard" USING btree ("testId", "userId");


--
-- Name: test_owner_id_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_owner_id_owner_type ON public."Test" USING btree ("ownerId", "ownerType");


--
-- Name: test_question_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_question_question_id ON public."TestQuestion" USING btree ("questionId");


--
-- Name: test_question_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_question_test_id ON public."TestQuestion" USING btree ("testId");


--
-- Name: topic_asset_asset_id_asset_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX topic_asset_asset_id_asset_type ON public."TopicAssetOld" USING btree ("assetId", "assetType");


--
-- Name: topic_asset_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX topic_asset_deleted ON public."TopicAssetOld" USING btree (deleted);


--
-- Name: topic_asset_owner_id_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX topic_asset_owner_id_owner_type ON public."TopicAssetOld" USING btree ("ownerId", "ownerType");


--
-- Name: topic_asset_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX topic_asset_topic_id ON public."TopicAssetOld" USING btree ("topicId");


--
-- Name: topic_leader_board_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX topic_leader_board_topic_id ON public."TopicLeaderBoard" USING btree ("topicId");


--
-- Name: topic_leader_board_user_id_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX topic_leader_board_user_id_topic_id ON public."TopicLeaderBoard" USING btree ("userId", "topicId");


--
-- Name: user_course_invitation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_course_invitation_id ON public."UserCourse" USING btree ("invitationId");


--
-- Name: user_course_user_id_course_id_expiryAt; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "user_course_user_id_course_id_expiryAt" ON public."UserCourse" USING btree ("userId", "courseId", "expiryAt");


--
-- Name: user_doubt_stat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_doubt_stat_id ON public."UserDoubtStat" USING btree (id);


--
-- Name: user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_email ON public."User" USING btree (email);


--
-- Name: user_highlighted_note_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_highlighted_note_note_id ON public."UserHighlightedNote" USING btree ("noteId");


--
-- Name: user_highlighted_note_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_highlighted_note_user_id ON public."UserHighlightedNote" USING btree ("userId");


--
-- Name: user_note_stat_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_note_stat_note_id ON public."UserNoteStat" USING btree ("noteId");


--
-- Name: user_note_stat_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_note_stat_user_id ON public."UserNoteStat" USING btree ("userId");


--
-- Name: user_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_phone ON public."User" USING btree (phone);


--
-- Name: user_profile_analytics_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_profile_analytics_user_id ON public."UserProfileAnalytic" USING btree ("userId");


--
-- Name: user_profile_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_profile_user_id ON public."UserProfile" USING btree ("userId");


--
-- Name: user_scheduled_task_scheduled_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_scheduled_task_scheduled_task_id ON public."UserScheduledTask" USING btree ("scheduledTaskId");


--
-- Name: user_scheduled_task_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_scheduled_task_user_id ON public."UserScheduledTask" USING btree ("userId");


--
-- Name: user_scheduled_task_user_id_scheduled_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_scheduled_task_user_id_scheduled_task_id ON public."UserScheduledTask" USING btree ("userId", "scheduledTaskId");


--
-- Name: user_task_progress_user_id_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_task_progress_user_id_schedule_id ON public."UserTaskProgress" USING btree ("userId", "scheduleId");


--
-- Name: user_task_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_task_task_id ON public."UserTask" USING btree ("taskId");


--
-- Name: user_task_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_task_user_id ON public."UserTask" USING btree ("userId");


--
-- Name: user_task_user_id_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_task_user_id_task_id ON public."UserTask" USING btree ("userId", "taskId");


--
-- Name: user_video_stat_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_video_stat_user_id ON public."UserVideoStat" USING btree ("userId");


--
-- Name: user_video_stat_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_video_stat_video_id ON public."UserVideoStat" USING btree ("videoId");


--
-- Name: video_link_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_link_video_id ON public."VideoLink" USING btree ("videoId");


--
-- Name: video_question_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_question_question_id ON public."VideoQuestion" USING btree ("questionId");


--
-- Name: video_question_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_question_video_id ON public."VideoQuestion" USING btree ("videoId");


--
-- Name: video_subTopic_subTopic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "video_subTopic_subTopic_id" ON public."VideoSubTopic" USING btree ("subTopicId");


--
-- Name: video_subTopic_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "video_subTopic_video_id" ON public."VideoSubTopic" USING btree ("videoId");


--
-- Name: video_test_test_id_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_test_test_id_video_id ON public."VideoTest" USING btree ("testId", "videoId");


--
-- Name: vote_owner_id_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vote_owner_id_owner_type ON public."Vote" USING btree ("ownerId", "ownerType");


--
-- Name: vote_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vote_user_id ON public."Vote" USING btree ("userId");


--
-- Name: work_logs_admin_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX work_logs_admin_user_id_idx ON public.work_logs USING btree (admin_user_id);


--
-- Name: VideoSubTopicQuestion _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public."VideoSubTopicQuestion" AS
 SELECT "Question".id,
    "VideoSubTopic"."videoId",
    "Question".id AS "questionId"
   FROM public."Question",
    public."QuestionSubTopic",
    public."VideoSubTopic",
    public."QuestionAnalytics26",
    public."ChapterQuestion",
    public."SubTopic",
    public."Topic",
    public."SubjectChapter",
    public."Subject"
  WHERE (("VideoSubTopic"."subTopicId" = "QuestionSubTopic"."subTopicId") AND ("Question".id = "QuestionSubTopic"."questionId") AND ("Question".id = "QuestionAnalytics26".id) AND ("QuestionAnalytics26"."difficultyLevel" = 'easy'::text) AND ("Question".deleted = false) AND ("Question".type = ANY (ARRAY['MCQ-SO'::public."enum_Question_type", 'MCQ-AR'::public."enum_Question_type"])) AND ("QuestionSubTopic"."subTopicId" = "SubTopic".id) AND ("SubTopic"."topicId" = "ChapterQuestion"."chapterId") AND ("ChapterQuestion"."questionId" = "Question".id) AND ("Topic".id = "ChapterQuestion"."chapterId") AND ("SubjectChapter"."chapterId" = "Topic".id) AND ("Subject".id = "SubjectChapter"."subjectId") AND ("Subject"."courseId" = 8));


--
-- Name: ChapterSubTopicWeightage _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public."ChapterSubTopicWeightage" AS
 SELECT "SubTopic".id AS "subTopicId",
    "SubTopic".name AS "subTopicName",
    "SubTopic"."topicId" AS "chapterId",
    count(DISTINCT "Question".id) AS "ncertQuestionCount",
    sum(count(DISTINCT "Question".id)) OVER (PARTITION BY "SubTopic"."topicId") AS "chapterCount",
    ((count(DISTINCT "Question".id))::numeric / sum(count(DISTINCT "Question".id)) OVER (PARTITION BY "SubTopic"."topicId")) AS weightage
   FROM public."CourseChapter",
    public."Question",
    public."QuestionSubTopic",
    public."SubTopic"
  WHERE (("QuestionSubTopic"."subTopicId" = "SubTopic".id) AND ("CourseChapter"."chapterId" = "SubTopic"."topicId") AND ("CourseChapter"."courseId" = 8) AND ("SubTopic"."videoOnly" = false) AND ("Question".id = "QuestionSubTopic"."questionId") AND ("Question".deleted = false) AND ("SubTopic".deleted = false) AND ("Question".ncert = true))
  GROUP BY "SubTopic".id, "SubTopic"."topicId";


--
-- Name: DuplicateQuestion question_similarity; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER question_similarity BEFORE INSERT OR UPDATE ON public."DuplicateQuestion" FOR EACH ROW EXECUTE PROCEDURE public.compute_similarity();


--
-- Name: TestAttempt test_attempt_history_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER test_attempt_history_update AFTER UPDATE ON public."TestAttempt" FOR EACH ROW EXECUTE PROCEDURE public.test_attempt_history_update();


--
-- Name: test test_history_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER test_history_delete AFTER DELETE ON public.test FOR EACH ROW EXECUTE PROCEDURE public.history_delete();


--
-- Name: test test_history_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER test_history_insert AFTER INSERT ON public.test FOR EACH ROW EXECUTE PROCEDURE public.history_insert();


--
-- Name: test test_history_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER test_history_update AFTER UPDATE ON public.test FOR EACH ROW EXECUTE PROCEDURE public.history_update();


--
-- Name: Answer Answer_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Answer"
    ADD CONSTRAINT "Answer_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Answer Answer_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Answer"
    ADD CONSTRAINT "Answer_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChapterMindmap ChapterMindmap_chapterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterMindmap"
    ADD CONSTRAINT "ChapterMindmap_chapterId_fkey" FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterMindmap ChapterMindmap_noteId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterMindmap"
    ADD CONSTRAINT "ChapterMindmap_noteId_fkey" FOREIGN KEY ("noteId") REFERENCES public."Note"(id);


--
-- Name: ChapterQuestionSet ChapterQuestionSet_chapterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionSet"
    ADD CONSTRAINT "ChapterQuestionSet_chapterId_fkey" FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterQuestionSet ChapterQuestionSet_testId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionSet"
    ADD CONSTRAINT "ChapterQuestionSet_testId_fkey" FOREIGN KEY ("testId") REFERENCES public."Test"(id);


--
-- Name: Comment Comment_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Comment"
    ADD CONSTRAINT "Comment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CourseOffer CourseOffer_admin_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseOffer"
    ADD CONSTRAINT "CourseOffer_admin_user_id_fkey" FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id);


--
-- Name: CourseOffer CourseOffer_courseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseOffer"
    ADD CONSTRAINT "CourseOffer_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES public."Course"(id);


--
-- Name: CourseTestimonial CourseTestimonial_courseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseTestimonial"
    ADD CONSTRAINT "CourseTestimonial_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES public."Course"(id);


--
-- Name: CustomerIssue CustomerIssue_adminUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT "CustomerIssue_adminUserId_fkey" FOREIGN KEY ("adminUserId") REFERENCES public.admin_users(id);


--
-- Name: CustomerIssue CustomerIssue_typeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT "CustomerIssue_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES public."CustomerIssueType"(id);


--
-- Name: CustomerIssue CustomerIssue_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT "CustomerIssue_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: DailyUserEvent DailyUserEvent_courseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyUserEvent"
    ADD CONSTRAINT "DailyUserEvent_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES public."Course"(id);


--
-- Name: DailyUserEvent DailyUserEvent_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyUserEvent"
    ADD CONSTRAINT "DailyUserEvent_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: DoubtAnswer DoubtAnswer_doubtId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DoubtAnswer"
    ADD CONSTRAINT "DoubtAnswer_doubtId_fkey" FOREIGN KEY ("doubtId") REFERENCES public."Doubt"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DoubtAnswer DoubtAnswer_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DoubtAnswer"
    ADD CONSTRAINT "DoubtAnswer_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt Doubt_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Doubt"
    ADD CONSTRAINT "Doubt_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt Doubt_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Doubt"
    ADD CONSTRAINT "Doubt_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DuplicateQuestion DuplicateQuestion_questionId1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicateQuestion"
    ADD CONSTRAINT "DuplicateQuestion_questionId1_fkey" FOREIGN KEY ("questionId1") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DuplicateQuestion DuplicateQuestion_questionId2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DuplicateQuestion"
    ADD CONSTRAINT "DuplicateQuestion_questionId2_fkey" FOREIGN KEY ("questionId2") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: NCERTQuestion NCERTQuestion_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NCERTQuestion"
    ADD CONSTRAINT "NCERTQuestion_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: NotDuplicateQuestion NotDuplicateQuestion_questionId1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotDuplicateQuestion"
    ADD CONSTRAINT "NotDuplicateQuestion_questionId1_fkey" FOREIGN KEY ("questionId1") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: NotDuplicateQuestion NotDuplicateQuestion_questionId2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotDuplicateQuestion"
    ADD CONSTRAINT "NotDuplicateQuestion_questionId2_fkey" FOREIGN KEY ("questionId2") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Payment Payment_courseOfferId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_courseOfferId_fkey" FOREIGN KEY ("courseOfferId") REFERENCES public."CourseOffer"(id);


--
-- Name: Payment Payment_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuestionCourse QuestionCourse_courseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionCourse"
    ADD CONSTRAINT "QuestionCourse_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES public."Course"(id);


--
-- Name: QuestionCourse QuestionCourse_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionCourse"
    ADD CONSTRAINT "QuestionCourse_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: QuestionNcertSentence QuestionNcertSentence_ncertSentenceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionNcertSentence"
    ADD CONSTRAINT "QuestionNcertSentence_ncertSentenceId_fkey" FOREIGN KEY ("ncertSentenceId") REFERENCES public."NcertSentence"(id);


--
-- Name: QuestionNcertSentence QuestionNcertSentence_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionNcertSentence"
    ADD CONSTRAINT "QuestionNcertSentence_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: QuestionTranslation QuestionTranslation_newQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionTranslation"
    ADD CONSTRAINT "QuestionTranslation_newQuestionId_fkey" FOREIGN KEY ("newQuestionId") REFERENCES public."Question"(id);


--
-- Name: QuestionTranslation QuestionTranslation_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionTranslation"
    ADD CONSTRAINT "QuestionTranslation_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: QuestionVimeo QuestionVimeo_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionVimeo"
    ADD CONSTRAINT "QuestionVimeo_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: Question Question_creatorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Question Question_originalQuestionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_originalQuestionId_fkey" FOREIGN KEY ("orignalQuestionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Question Question_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id);


--
-- Name: RemovedSyllabusSubTopic RemovedSyllabusSubTopic_chapterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RemovedSyllabusSubTopic"
    ADD CONSTRAINT "RemovedSyllabusSubTopic_chapterId_fkey" FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: RemovedSyllabusSubTopic RemovedSyllabusSubTopic_subTopicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RemovedSyllabusSubTopic"
    ADD CONSTRAINT "RemovedSyllabusSubTopic_subTopicId_fkey" FOREIGN KEY ("subTopicId") REFERENCES public."SubTopic"(id);


--
-- Name: StudentNote StudentNote_noteId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudentNote"
    ADD CONSTRAINT "StudentNote_noteId_fkey" FOREIGN KEY ("noteId") REFERENCES public."Note"(id);


--
-- Name: StudentNote StudentNote_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudentNote"
    ADD CONSTRAINT "StudentNote_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public."Video"(id);


--
-- Name: SubTopic SubTopic_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubTopic"
    ADD CONSTRAINT "SubTopic_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Subject Subject_courseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Subject"
    ADD CONSTRAINT "Subject_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES public."Course"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Topic Topic_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic"
    ADD CONSTRAINT "Topic_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserClaim UserClaim_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserClaim"
    ADD CONSTRAINT "UserClaim_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserCourse UserCourse_courseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserCourse"
    ADD CONSTRAINT "UserCourse_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES public."Course"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserCourse UserCourse_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserCourse"
    ADD CONSTRAINT "UserCourse_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserProfile UserProfile_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserProfile"
    ADD CONSTRAINT "UserProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: VideoAnnotation VideoAnnotation_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoAnnotation"
    ADD CONSTRAINT "VideoAnnotation_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public."Video"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: VideoTest VideoTest_testId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoTest"
    ADD CONSTRAINT "VideoTest_testId_fkey" FOREIGN KEY ("testId") REFERENCES public."Test"(id);


--
-- Name: VideoTest VideoTest_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoTest"
    ADD CONSTRAINT "VideoTest_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public."Video"(id);


--
-- Name: Video Video_creatorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Video"
    ADD CONSTRAINT "Video_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_note_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT customer_issue_note_id_fkey FOREIGN KEY ("noteId") REFERENCES public."Note"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT customer_issue_question_id_fkey FOREIGN KEY ("questionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT customer_issue_test_id_fkey FOREIGN KEY ("testId") REFERENCES public."Test"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT customer_issue_topic_id_fkey FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerIssue"
    ADD CONSTRAINT customer_issue_video_id_fkey FOREIGN KEY ("videoId") REFERENCES public."Video"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt doubt_note_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Doubt"
    ADD CONSTRAINT doubt_note_id_fkey FOREIGN KEY ("noteId") REFERENCES public."Note"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt doubt_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Doubt"
    ADD CONSTRAINT doubt_question_id_fkey FOREIGN KEY ("questionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt doubt_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Doubt"
    ADD CONSTRAINT doubt_test_id_fkey FOREIGN KEY ("testId") REFERENCES public."Test"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FcmToken fcm_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FcmToken"
    ADD CONSTRAINT fcm_token_user_id_fkey FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChapterNote fk_chapter_note_chapterid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterNote"
    ADD CONSTRAINT fk_chapter_note_chapterid FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterNote fk_chapter_note_noteid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterNote"
    ADD CONSTRAINT fk_chapter_note_noteid FOREIGN KEY ("noteId") REFERENCES public."Note"(id);


--
-- Name: ChapterQuestion fk_chapter_question_chapterid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestion"
    ADD CONSTRAINT fk_chapter_question_chapterid FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterQuestionCopy fk_chapter_question_chapterid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionCopy"
    ADD CONSTRAINT fk_chapter_question_chapterid FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterQuestion fk_chapter_question_questionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestion"
    ADD CONSTRAINT fk_chapter_question_questionid FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: ChapterQuestionCopy fk_chapter_question_questionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterQuestionCopy"
    ADD CONSTRAINT fk_chapter_question_questionid FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: ChapterTask fk_chapter_task_chapterid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTask"
    ADD CONSTRAINT fk_chapter_task_chapterid FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterTask fk_chapter_task_taskid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTask"
    ADD CONSTRAINT fk_chapter_task_taskid FOREIGN KEY ("taskId") REFERENCES public."Task"(id);


--
-- Name: ChapterTest fk_chapter_test_chapterid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTest"
    ADD CONSTRAINT fk_chapter_test_chapterid FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterTest fk_chapter_test_testid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterTest"
    ADD CONSTRAINT fk_chapter_test_testid FOREIGN KEY ("testId") REFERENCES public."Test"(id);


--
-- Name: ChapterVideo fk_chapter_video_chapterid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterVideo"
    ADD CONSTRAINT fk_chapter_video_chapterid FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterVideo fk_chapter_video_videoid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterVideo"
    ADD CONSTRAINT fk_chapter_video_videoid FOREIGN KEY ("videoId") REFERENCES public."Video"(id);


--
-- Name: CourseTest fk_course_test_courseid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseTest"
    ADD CONSTRAINT fk_course_test_courseid FOREIGN KEY ("courseId") REFERENCES public."Course"(id);


--
-- Name: CourseTest fk_course_test_testid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseTest"
    ADD CONSTRAINT fk_course_test_testid FOREIGN KEY ("testId") REFERENCES public."Test"(id);


--
-- Name: NcertChapterQuestion fk_ncert_chapter_question_chapterid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertChapterQuestion"
    ADD CONSTRAINT fk_ncert_chapter_question_chapterid FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: NcertChapterQuestion fk_ncert_chapter_question_questionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertChapterQuestion"
    ADD CONSTRAINT fk_ncert_chapter_question_questionid FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: QuestionSubTopic fk_question_subtopic_questionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionSubTopic"
    ADD CONSTRAINT fk_question_subtopic_questionid FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: QuestionSubTopic fk_question_subtopic_subtopicid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionSubTopic"
    ADD CONSTRAINT fk_question_subtopic_subtopicid FOREIGN KEY ("subTopicId") REFERENCES public."SubTopic"(id);


--
-- Name: Test fk_rails_016fa67182; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Test"
    ADD CONSTRAINT fk_rails_016fa67182 FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: UserTodo fk_rails_058d2d272e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTodo"
    ADD CONSTRAINT fk_rails_058d2d272e FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id);


--
-- Name: NcertSentence fk_rails_2255827ede; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertSentence"
    ADD CONSTRAINT fk_rails_2255827ede FOREIGN KEY ("sectionId") REFERENCES public."Section"(id);


--
-- Name: CourseDetail fk_rails_259449bff2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseDetail"
    ADD CONSTRAINT fk_rails_259449bff2 FOREIGN KEY ("courseId") REFERENCES public."Course"(id);


--
-- Name: user_actions fk_rails_2796d61ea0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT fk_rails_2796d61ea0 FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: UserTodo fk_rails_2f3b933224; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTodo"
    ADD CONSTRAINT fk_rails_2f3b933224 FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: UserTodo fk_rails_322f64ccd2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTodo"
    ADD CONSTRAINT fk_rails_322f64ccd2 FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: CustomerSupport fk_rails_334df1fef4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerSupport"
    ADD CONSTRAINT fk_rails_334df1fef4 FOREIGN KEY ("adminUserId") REFERENCES public.admin_users(id);


--
-- Name: NcertSentence fk_rails_47b15e840e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertSentence"
    ADD CONSTRAINT fk_rails_47b15e840e FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: CourseInvitation fk_rails_52b958d86d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CourseInvitation"
    ADD CONSTRAINT fk_rails_52b958d86d FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id);


--
-- Name: UserDpp fk_rails_53e1646167; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserDpp"
    ADD CONSTRAINT fk_rails_53e1646167 FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: StudentOnboardingEvents fk_rails_57a5cd7155; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StudentOnboardingEvents"
    ADD CONSTRAINT fk_rails_57a5cd7155 FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: doubt_chat_doubt_answers fk_rails_5cb473102b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_chat_doubt_answers
    ADD CONSTRAINT fk_rails_5cb473102b FOREIGN KEY (doubt_chat_doubt_id) REFERENCES public.doubt_chat_doubts(id);


--
-- Name: student_coaches fk_rails_5d22b2e06e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_coaches
    ADD CONSTRAINT fk_rails_5d22b2e06e FOREIGN KEY ("studentId") REFERENCES public."User"(id);


--
-- Name: Section fk_rails_69f13a1696; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Section"
    ADD CONSTRAINT fk_rails_69f13a1696 FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: QuestionVideoSentence fk_rails_8593383ffd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionVideoSentence"
    ADD CONSTRAINT fk_rails_8593383ffd FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: student_coaches fk_rails_88f9034dec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_coaches
    ADD CONSTRAINT fk_rails_88f9034dec FOREIGN KEY ("coachId") REFERENCES public.admin_users(id);


--
-- Name: VideoSentence fk_rails_907af9df59; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSentence"
    ADD CONSTRAINT fk_rails_907af9df59 FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: ChapterFlashCard fk_rails_9414c57a02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterFlashCard"
    ADD CONSTRAINT fk_rails_9414c57a02 FOREIGN KEY ("flashCardId") REFERENCES public."FlashCard"(id);


--
-- Name: ChapterFlashCard fk_rails_951f27dd9a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterFlashCard"
    ADD CONSTRAINT fk_rails_951f27dd9a FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: UserFlashCard fk_rails_997fa74b62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFlashCard"
    ADD CONSTRAINT fk_rails_997fa74b62 FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: ChapterGlossary fk_rails_99bcc2b2ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterGlossary"
    ADD CONSTRAINT fk_rails_99bcc2b2ef FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: UserFlashCard fk_rails_9a2726adae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFlashCard"
    ADD CONSTRAINT fk_rails_9a2726adae FOREIGN KEY ("flashCardId") REFERENCES public."FlashCard"(id);


--
-- Name: NcertSentence fk_rails_9d470d60a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NcertSentence"
    ADD CONSTRAINT fk_rails_9d470d60a2 FOREIGN KEY ("noteId") REFERENCES public."Note"(id);


--
-- Name: version_associations fk_rails_a20d5f0c08; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_associations
    ADD CONSTRAINT fk_rails_a20d5f0c08 FOREIGN KEY (version_id) REFERENCES public.versions(id);


--
-- Name: doubt_admins fk_rails_a317c597bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_admins
    ADD CONSTRAINT fk_rails_a317c597bf FOREIGN KEY ("doubtId") REFERENCES public."Doubt"(id);


--
-- Name: Target fk_rails_a57307e52b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Target"
    ADD CONSTRAINT fk_rails_a57307e52b FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: PaymentConversion fk_rails_ab1bd31480; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentConversion"
    ADD CONSTRAINT fk_rails_ab1bd31480 FOREIGN KEY ("paymentId") REFERENCES public."Payment"(id);


--
-- Name: TargetChapter fk_rails_acd040cb85; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TargetChapter"
    ADD CONSTRAINT fk_rails_acd040cb85 FOREIGN KEY ("chapterId") REFERENCES public."Topic"(id);


--
-- Name: UserResult fk_rails_b38a96ebdf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserResult"
    ADD CONSTRAINT fk_rails_b38a96ebdf FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: ChapterGlossary fk_rails_b426e0b75b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChapterGlossary"
    ADD CONSTRAINT fk_rails_b426e0b75b FOREIGN KEY ("glossaryId") REFERENCES public."Glossary"(id);


--
-- Name: doubt_chat_doubts fk_rails_b5b3bf45b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doubt_chat_doubts
    ADD CONSTRAINT fk_rails_b5b3bf45b3 FOREIGN KEY (doubt_chat_channel_id) REFERENCES public.doubt_chat_channels(id);


--
-- Name: TargetChapter fk_rails_b94a981115; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TargetChapter"
    ADD CONSTRAINT fk_rails_b94a981115 FOREIGN KEY ("targetId") REFERENCES public."Target"(id);


--
-- Name: VideoSentence fk_rails_bfb381278a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSentence"
    ADD CONSTRAINT fk_rails_bfb381278a FOREIGN KEY ("videoId") REFERENCES public."Video"(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: VideoSentence fk_rails_c95acbd4c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSentence"
    ADD CONSTRAINT fk_rails_c95acbd4c7 FOREIGN KEY ("sectionId") REFERENCES public."Section"(id);


--
-- Name: SectionContent fk_rails_ccea17349b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SectionContent"
    ADD CONSTRAINT fk_rails_ccea17349b FOREIGN KEY ("sectionId") REFERENCES public."Section"(id);


--
-- Name: QuestionVideoSentence fk_rails_ced843e9fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuestionVideoSentence"
    ADD CONSTRAINT fk_rails_ced843e9fe FOREIGN KEY ("videoSentenceId") REFERENCES public."VideoSentence"(id);


--
-- Name: UserDpp fk_rails_fc0653ccaa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserDpp"
    ADD CONSTRAINT fk_rails_fc0653ccaa FOREIGN KEY ("testId") REFERENCES public."Test"(id);


--
-- Name: ScheduleItem fk_schedule_item_schedule; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItem"
    ADD CONSTRAINT fk_schedule_item_schedule FOREIGN KEY ("scheduleId") REFERENCES public."Schedule"(id);


--
-- Name: ScheduleItem fk_schedule_item_topic; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItem"
    ADD CONSTRAINT fk_schedule_item_topic FOREIGN KEY ("topicId") REFERENCES public."Topic"(id);


--
-- Name: ScheduleItemUser fk_schedule_item_user_schedule_item; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItemUser"
    ADD CONSTRAINT fk_schedule_item_user_schedule_item FOREIGN KEY ("scheduleItemId") REFERENCES public."ScheduleItem"(id);


--
-- Name: ScheduleItemUser fk_schedule_item_user_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduleItemUser"
    ADD CONSTRAINT fk_schedule_item_user_user FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: TestQuestion fk_test_question_questionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestQuestion"
    ADD CONSTRAINT fk_test_question_questionid FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: TestQuestion fk_test_question_testid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestQuestion"
    ADD CONSTRAINT fk_test_question_testid FOREIGN KEY ("testId") REFERENCES public."Test"(id);


--
-- Name: UserLogin fk_user_login_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserLogin"
    ADD CONSTRAINT fk_user_login_user FOREIGN KEY ("userId") REFERENCES public."User"(id);


--
-- Name: VideoQuestion fk_video_question_questionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoQuestion"
    ADD CONSTRAINT fk_video_question_questionid FOREIGN KEY ("questionId") REFERENCES public."Question"(id);


--
-- Name: VideoQuestion fk_video_question_videoid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoQuestion"
    ADD CONSTRAINT fk_video_question_videoid FOREIGN KEY ("videoId") REFERENCES public."Video"(id);


--
-- Name: VideoSubTopic fk_video_subtopic_subtopicid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSubTopic"
    ADD CONSTRAINT fk_video_subtopic_subtopicid FOREIGN KEY ("subTopicId") REFERENCES public."Video"(id);


--
-- Name: VideoSubTopic fk_video_subtopic_videoid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoSubTopic"
    ADD CONSTRAINT fk_video_subtopic_videoid FOREIGN KEY ("videoId") REFERENCES public."Video"(id);


--
-- Name: UserCourse invitationId_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserCourse"
    ADD CONSTRAINT "invitationId_fk" FOREIGN KEY ("invitationId") REFERENCES public."CourseInvitation"(id) ON DELETE CASCADE;


--
-- Name: Notification notification_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT notification_user_id_fkey FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO public,google_ads;

INSERT INTO "schema_migrations" (version) VALUES
('20190516080816'),
('20190516081813'),
('20190523054853'),
('20190527055752'),
('20190703122841'),
('20190712115059'),
('20190820114330'),
('20190911070437'),
('20190920100046'),
('20191017085922'),
('20191017094016'),
('20191017114507'),
('20191021115016'),
('20191107103200'),
('20191118061437'),
('20191202121739'),
('20191216134552'),
('20191220125601'),
('20191223131103'),
('20191227074525'),
('20200103044530'),
('20200103052947'),
('20200120065055'),
('20200120101941'),
('20200121082410'),
('20200121110528'),
('20200123085448'),
('20200124120957'),
('20200131070012'),
('20200207121248'),
('20200210051222'),
('20200210053638'),
('20200210055726'),
('20200212095316'),
('20200302051557'),
('20200302051918'),
('20200302052953'),
('20200325081700'),
('20200401120355'),
('20200401124825'),
('20200402111747'),
('20200403101324'),
('20200506111147'),
('20200507080927'),
('20200507131123'),
('20200525092930'),
('20200525094704'),
('20200605124449'),
('20200609072958'),
('20200609072959'),
('20200715130504'),
('20200716115340'),
('20200818085233'),
('20200918024216'),
('20200919055744'),
('20200928131142'),
('20201005072637'),
('20201008171001'),
('20201028114527'),
('20201029051147'),
('20201029051148'),
('20201029082755'),
('20201102122835'),
('20201102124603'),
('20201103054100'),
('20201103105101'),
('20201110102717'),
('20201110113505'),
('20201112141620'),
('20201112141621'),
('20201112141622'),
('20201112141623'),
('20201112141624'),
('20201124045410'),
('20201130082410'),
('20201217100134'),
('20201217100135'),
('20201221104331'),
('20201221113137'),
('20210202102223'),
('20210208071043'),
('20210211061357'),
('20210212061637'),
('20210212084401'),
('20210316123522'),
('20210421065723'),
('20210426103243'),
('20210531062211'),
('20210531124523'),
('20210602041533'),
('20210611075034'),
('20210624102840'),
('20210706105329'),
('20210706140821'),
('20210709103127'),
('20210709104030'),
('20210811061300'),
('20210830111613');


