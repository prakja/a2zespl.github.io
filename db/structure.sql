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
-- Name: RubyActiveAdmin_test; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA RubyActiveAdmin_test;


--
-- Name: SCHEMA RubyActiveAdmin_test; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA RubyActiveAdmin_test IS 'standard RubyActiveAdmin_test schema';


--
-- Name: enum_Advertisement_platform; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Advertisement_platform" AS ENUM (
    'website',
    'mobile',
    'both'
);


--
-- Name: enum_Coupon_discountType; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Coupon_discountType" AS ENUM (
    'percentage',
    'absolute'
);


--
-- Name: enum_CourseInvitation_role; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_CourseInvitation_role" AS ENUM (
    'courseStudent',
    'courseManager',
    'courseCreator',
    'courseAdmin'
);


--
-- Name: enum_Course_package; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Course_package" AS ENUM (
    'k12',
    'iit',
    'neet',
    'bionks',
    'iitpariksha',
    'neetpariksha'
);


--
-- Name: enum_Doubt_doubtType; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Doubt_doubtType" AS ENUM (
    'Content_Issue',
    'Wrong_Answer',
    'Wrong_Explanation',
    'Insufficient_Explanation',
    'Problem_With_Playback',
    'Wrong_Question',
    'Question_Not_Related_To_Topic',
    'Spelling_Mistakes',
    'Academic_Doubt',
    'Website_Not_Working_Properly'
);


--
-- Name: enum_Message_type; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Message_type" AS ENUM (
    'normal',
    'joinChat',
    'leftChat',
    'analytics',
    'pdf',
    'question'
);


--
-- Name: enum_Payment_status; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Payment_status" AS ENUM (
    'created',
    'requestSent',
    'responseReceivedSuccess',
    'responseReceivedFailure'
);


--
-- Name: enum_Question_level; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Question_level" AS ENUM (
    'BASIC-NCERT',
    'MASTER-NCERT'
);


--
-- Name: enum_Question_type; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Question_type" AS ENUM (
    'MCQ-SO',
    'MCQ-AR',
    'MCQ-MO',
    'SUBJECTIVE'
);


--
-- Name: enum_SOS_gender; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_SOS_gender" AS ENUM (
    'Male',
    'Female'
);


--
-- Name: enum_Test_exam; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_Test_exam" AS ENUM (
    'AIIMS',
    'NEET',
    'AIPMT',
    'JIPMER'
);


--
-- Name: enum_UserCourse_role; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_UserCourse_role" AS ENUM (
    'courseStudent',
    'courseManager',
    'courseCreator',
    'courseAdmin'
);


--
-- Name: enum_UserProfile_gender; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test."enum_UserProfile_gender" AS ENUM (
    'Male',
    'Female'
);


--
-- Name: jwt_token; Type: TYPE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TYPE RubyActiveAdmin_test.jwt_token AS (
	role text,
	userid integer
);


--
-- Name: AddCourseOfferForShortDurationCourse(); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."AddCourseOfferForShortDurationCourse"() RETURNS void
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
-- Name: CreateCourseAccessForZeroFee(); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."CreateCourseAccessForZeroFee"() RETURNS void
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
    INSERT INTO RubyActiveAdmin_test."UserCourse"
("startedAt", "expiryAt", "role", "courseId", "userId", "couponId", trial, "invitationId", "courseOfferId")
select current_timestamp, "t_row"."expiryAt", 'courseStudent', "t_row"."courseId", user_row."id", NULL, true, NULL, "t_row"."id"
 from user_row;
 update "CourseOffer" set "accepted"=true where "id"="t_row"."id";
end loop;
END
$$;


--
-- Name: InsertSelectQuestions(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."InsertSelectQuestions"(chapterid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  insert into "ChapterQuestion" ("chapterId", "questionId") select (select "dupId" from "DuplicateChapter", "SubjectChapter" where "origId" = chapterId and "SubjectChapter"."chapterId" = "DuplicateChapter"."dupId" and "SubjectChapter"."subjectId" = 727), "id" from "Question" where "id" in (select "questionId" from "ChapterQuestion" where "chapterId" = chapterId) and "deleted" = false and "explanation" ilike '%page%';
END
$$;


--
-- Name: LongRunningQueries(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."LongRunningQueries"(minutes integer DEFAULT 1) RETURNS TABLE(processid integer, dur interval, q text, s text)
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
-- Name: PopulateDailyUserCourseEvent(integer, integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."PopulateDailyUserCourseEvent"(days integer DEFAULT 1, courseid integer DEFAULT 255) RETURNS void
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
-- Name: PopulateDailyUserEvent(integer, date); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."PopulateDailyUserEvent"(days integer DEFAULT 1, startdate date DEFAULT '2020-01-01'::date) RETURNS void
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
-- Name: SetChapterFlashCardSeq(boolean); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."SetChapterFlashCardSeq"(forcerefresh boolean DEFAULT false) RETURNS void
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
-- Name: SetChapterFlashCardSeq(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."SetChapterFlashCardSeq"(chapterid integer) RETURNS void
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
-- Name: SyncChapterQuestions(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."SyncChapterQuestions"(chapterid integer) RETURNS void
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
-- Name: SyncCourseQuestions(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."SyncCourseQuestions"(courseid integer) RETURNS void
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
-- Name: SyncSubjectQuestions(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."SyncSubjectQuestions"(subjectid integer) RETURNS void
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
-- Name: TestAttemptDetailFunc(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."TestAttemptDetailFunc"(usertestattemptid integer) RETURNS boolean
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
          WHERE "User".id = "UserCourse"."userId" AND "UserCourse"."courseId" = "Subject"."courseId" AND "Subject".id = "SubjectChapter"."subjectId" AND "SubjectChapter"."chapterId" = "Topic".id AND "UserCourse"."expiryAt" >= now() AND "SubjectChapter".deleted = false AND "Topic".free <> true) UserChapter ON UserChapter."chapterId" = "ChapterTest"."chapterId" AND (UserChapter."userId" = "TestAttempt"."userId")
  GROUP BY "TestAttempt".id into showAnswer;
return showAnswer;
END
$$;


--
-- Name: _final_median(numeric[]); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test._final_median(numeric[]) RETURNS numeric
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
-- Name: duplicateChapterQuestions(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."duplicateChapterQuestions"(chapterid integer) RETURNS void
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
-- Name: duplicateChapterQuestions(integer, integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."duplicateChapterQuestions"(questionid integer, chapterid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  with asQuestion as (insert into "Question" ("question","explanation","options","correctOptionIndex","type","deleted","paidAccess","level","sequenceId","orignalQuestionId","topicId","subjectId","createdAt","updatedAt") select "question","explanation","options","correctOptionIndex","type","deleted","paidAccess","level","sequenceId","id","topicId","subjectId",current_timestamp,current_timestamp from "Question" where "id"= questionId RETURNING id) update "ChapterQuestion" set "questionId"=(select id from asQuestion) where "chapterId"=chapterId and "questionId"=questionId;
END
$$;


--
-- Name: history_delete(); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test.history_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO history(event_time, executed_by, origin_value)
     VALUES(CURRENT_TIMESTAMP, SESSION_USER, row_to_json(OLD)::jsonb);
  RETURN NEW;
END;
$$;


--
-- Name: history_insert(); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test.history_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO history(event_time, executed_by, new_value)
     VALUES(CURRENT_TIMESTAMP, SESSION_USER, row_to_json(NEW)::jsonb);
  RETURN NEW;
END;
$$;


--
-- Name: history_update(); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test.history_update() RETURNS trigger
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
-- Name: jsonb_delete_left(jsonb, text[]); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test.jsonb_delete_left(a jsonb, b text[]) RETURNS jsonb
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
-- Name: FUNCTION jsonb_delete_left(a jsonb, b text[]); Type: COMMENT; Schema: RubyActiveAdmin_test; Owner: -
--

COMMENT ON FUNCTION RubyActiveAdmin_test.jsonb_delete_left(a jsonb, b text[]) IS 'delete keys in second argument from first argument';


--
-- Name: jsonb_delete_left(jsonb, jsonb); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test.jsonb_delete_left(a jsonb, b jsonb) RETURNS jsonb
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
-- Name: FUNCTION jsonb_delete_left(a jsonb, b jsonb); Type: COMMENT; Schema: RubyActiveAdmin_test; Owner: -
--

COMMENT ON FUNCTION RubyActiveAdmin_test.jsonb_delete_left(a jsonb, b jsonb) IS 'delete matching pairs in second argument from first argument';


--
-- Name: jsonb_delete_left(jsonb, text); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test.jsonb_delete_left(a jsonb, b text) RETURNS jsonb
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
-- Name: FUNCTION jsonb_delete_left(a jsonb, b text); Type: COMMENT; Schema: RubyActiveAdmin_test; Owner: -
--

COMMENT ON FUNCTION RubyActiveAdmin_test.jsonb_delete_left(a jsonb, b text) IS 'delete key in second argument from first argument';


--
-- Name: test_attempt_history_update(); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test.test_attempt_history_update() RETURNS trigger
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
-- Name: updateCourseLiveSessionQuestionExplanation(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."updateCourseLiveSessionQuestionExplanation"(courseid integer) RETURNS void
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
-- Name: updateLiveSessionQuestionExplanation(integer); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."updateLiveSessionQuestionExplanation"(testid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
Update "Question" set "explanation" = concat ("explanation", '<p>Question No: <b>', c."rowNum", '</b> from Live Session Link Below</p>', "Test"."resultMsgHtml") from "TestQuestion", "Test", (select "questionId", row_number() over (order by "TestQuestion"."questionId" asc) as "rowNum" from "TestQuestion" where "testId" = testId) as c where "testId" = testId and "Test"."id" = "TestQuestion"."testId" and "Question"."id" = "TestQuestion"."questionId" and c."questionId" = "Question"."id" and ("Question"."explanation" is null or "Question"."explanation" = '') and "resultMsgHtml" like '%youtu%';   
END
$$;


--
-- Name: updateQuestionSubjectId(); Type: FUNCTION; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE FUNCTION RubyActiveAdmin_test."updateQuestionSubjectId"() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE "Question" set "subjectId" = "SubjectChapter"."subjectId" from "SubjectChapter" where "SubjectChapter"."chapterId" = "Question"."topicId" and "SubjectChapter"."subjectId" in (53,54,55,56) and "Question"."subjectId" is null ;
END
$$;


--
-- Name: median(numeric); Type: AGGREGATE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE AGGREGATE RubyActiveAdmin_test.median(numeric) (
    SFUNC = array_append,
    STYPE = numeric[],
    INITCOND = '{}',
    FINALFUNC = RubyActiveAdmin_test._final_median
);


--
-- Name: -; Type: OPERATOR; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE OPERATOR RubyActiveAdmin_test.- (
    FUNCTION = RubyActiveAdmin_test.jsonb_delete_left,
    LEFTARG = jsonb,
    RIGHTARG = text
);


--
-- Name: -; Type: OPERATOR; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE OPERATOR RubyActiveAdmin_test.- (
    FUNCTION = RubyActiveAdmin_test.jsonb_delete_left,
    LEFTARG = jsonb,
    RIGHTARG = text[]
);


--
-- Name: -; Type: OPERATOR; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE OPERATOR RubyActiveAdmin_test.- (
    FUNCTION = RubyActiveAdmin_test.jsonb_delete_left,
    LEFTARG = jsonb,
    RIGHTARG = jsonb
);


--
-- Name: OPERATOR - (jsonb, jsonb); Type: COMMENT; Schema: RubyActiveAdmin_test; Owner: -
--

COMMENT ON OPERATOR RubyActiveAdmin_test.- (jsonb, jsonb) IS 'delete matching pairs from left operand';


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
-- Name: ActiveFlashCardChapter; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ActiveFlashCardChapter" (
    id bigint NOT NULL,
    "chapterId" integer
);


--
-- Name: ActiveFlashCardChapter_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ActiveFlashCardChapter_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ActiveFlashCardChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ActiveFlashCardChapter_id_seq" OWNED BY RubyActiveAdmin_test."ActiveFlashCardChapter".id;


--
-- Name: Advertisement; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Advertisement" (
    id integer NOT NULL,
    "webUrl" character varying(255) NOT NULL,
    "mobileUrl" character varying(255) NOT NULL,
    "startedAt" timestamp with time zone NOT NULL,
    "expiryAt" timestamp with time zone NOT NULL,
    platform RubyActiveAdmin_test."enum_Advertisement_platform" DEFAULT 'both'::RubyActiveAdmin_test."enum_Advertisement_platform",
    link character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "backgroundColor" character varying(255),
    context jsonb
);


--
-- Name: Advertisement_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Advertisement_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Advertisement_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Advertisement_id_seq" OWNED BY RubyActiveAdmin_test."Advertisement".id;


--
-- Name: Announcement; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Announcement" (
    id integer NOT NULL,
    title character varying(255),
    content text,
    "userId" integer,
    "courseId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Announcement_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Announcement_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Announcement_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Announcement_id_seq" OWNED BY RubyActiveAdmin_test."Announcement".id;


--
-- Name: Answer; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Answer" (
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
-- Name: Answer_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Answer_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Answer_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Answer_id_seq" OWNED BY RubyActiveAdmin_test."Answer".id;


--
-- Name: AppVersion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."AppVersion" (
    id integer NOT NULL,
    name character varying(255),
    version character varying(255),
    description text,
    "forceUpdate" boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: AppVersion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."AppVersion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: AppVersion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."AppVersion_id_seq" OWNED BY RubyActiveAdmin_test."AppVersion".id;


--
-- Name: BiologyChapterNCERTSeq; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."BiologyChapterNCERTSeq" (
    "chapterId" integer NOT NULL,
    "seqId" integer NOT NULL,
    class integer NOT NULL
);


--
-- Name: Question; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Question" (
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
    type RubyActiveAdmin_test."enum_Question_type" DEFAULT 'MCQ-SO'::RubyActiveAdmin_test."enum_Question_type" NOT NULL,
    "paidAccess" boolean DEFAULT false,
    "explanationMp4" text,
    level RubyActiveAdmin_test."enum_Question_level",
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
-- Name: QuestionDetail; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."QuestionDetail" (
    id integer NOT NULL,
    year integer,
    exam character varying(255),
    "examName" text,
    "questionId" integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: BoardExamQuestion; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."BoardExamQuestion" AS
 SELECT "Question".id,
    "Question".deleted
   FROM RubyActiveAdmin_test."Question"
  WHERE (EXISTS ( SELECT 1
           FROM RubyActiveAdmin_test."QuestionDetail"
          WHERE (("Question".id = "QuestionDetail"."questionId") AND (("QuestionDetail".exam)::text = 'BOARD'::text))));


--
-- Name: BookmarkQuestion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."BookmarkQuestion" (
    id integer NOT NULL,
    "questionId" integer NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: BookmarkQuestion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."BookmarkQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookmarkQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."BookmarkQuestion_id_seq" OWNED BY RubyActiveAdmin_test."BookmarkQuestion".id;


--
-- Name: ChapterQuestionCopy; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestionCopy" (
    id integer NOT NULL,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ChapterQuestion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChapterQuestion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChapterQuestion_id_seq" OWNED BY RubyActiveAdmin_test."ChapterQuestionCopy".id;


--
-- Name: ChapterQuestion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestion" (
    id integer DEFAULT nextval('RubyActiveAdmin_test."ChapterQuestion_id_seq"'::regclass) NOT NULL,
    "chapterId" integer NOT NULL,
    "questionId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: Topic; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Topic" (
    id integer NOT NULL,
    name character varying(255),
    image text,
    description text,
    "position" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "subjectId" integer,
    free boolean DEFAULT false NOT NULL,
    published boolean DEFAULT false NOT NULL,
    "seqId" integer DEFAULT 0 NOT NULL,
    "importUrl" character varying(255),
    "isComingSoon" boolean DEFAULT false,
    "sectionReady" boolean DEFAULT false
);


--
-- Name: User; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."User" (
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
-- Name: ChapQuesUserAnswer; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."ChapQuesUserAnswer" AS
 SELECT ((("User".id - 1) * ( SELECT count(*) AS count
           FROM RubyActiveAdmin_test."Topic" "Topic_1")) + "Topic".id) AS id,
    "Topic".id AS "topicId",
    "User".id AS "userId",
    json_object_agg("Question".id, "Answer"."userAnswer") AS "userAnswers"
   FROM RubyActiveAdmin_test."Topic",
    RubyActiveAdmin_test."User",
    RubyActiveAdmin_test."ChapterQuestion",
    RubyActiveAdmin_test."Question",
    RubyActiveAdmin_test."Answer"
  WHERE (("Topic".id = "ChapterQuestion"."chapterId") AND ("ChapterQuestion"."questionId" = "Question".id) AND ("Question".id = "Answer"."questionId") AND ("User".id = "Answer"."userId"))
  GROUP BY "Topic".id, "User".id;


--
-- Name: ChapterFlashCard; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterFlashCard" (
    id bigint NOT NULL,
    "chapterId" integer NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "flashCardId" integer NOT NULL,
    "seqId" integer
);


--
-- Name: ChapterFlashCard20200609; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterFlashCard20200609" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: ChapterFlashCard20200924; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterFlashCard20200924" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: ChapterFlashCardCopy; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterFlashCardCopy" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: ChapterFlashCard_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChapterFlashCard_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterFlashCard_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChapterFlashCard_id_seq" OWNED BY RubyActiveAdmin_test."ChapterFlashCard".id;


--
-- Name: ChapterGlossary; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterGlossary" (
    id bigint NOT NULL,
    "chapterId" integer,
    "glossaryId" integer,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    frequency integer
);


--
-- Name: ChapterGlossary_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChapterGlossary_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterGlossary_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChapterGlossary_id_seq" OWNED BY RubyActiveAdmin_test."ChapterGlossary".id;


--
-- Name: ChapterMindmap; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterMindmap" (
    id integer NOT NULL,
    "chapterId" integer NOT NULL,
    "noteId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ChapterMindmap_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChapterMindmap_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterMindmap_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChapterMindmap_id_seq" OWNED BY RubyActiveAdmin_test."ChapterMindmap".id;


--
-- Name: ChapterNote; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterNote" (
    id integer NOT NULL,
    "chapterId" integer,
    "noteId" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ChapterNote_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChapterNote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterNote_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChapterNote_id_seq" OWNED BY RubyActiveAdmin_test."ChapterNote".id;


--
-- Name: ChapterQuestion20200516; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestion20200516" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20200528; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestion20200528" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20200929; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestion20200929" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20201005; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestion20201005" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20211801; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestion20211801" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20211801_1; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestion20211801_1" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterQuestion20211801_2; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterQuestion20211801_2" (
    id integer,
    "chapterId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: ChapterTask; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterTask" (
    id integer NOT NULL,
    "chapterId" integer,
    "taskId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ChapterTask_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChapterTask_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterTask_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChapterTask_id_seq" OWNED BY RubyActiveAdmin_test."ChapterTask".id;


--
-- Name: ChapterTest; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterTest" (
    id integer NOT NULL,
    "chapterId" integer NOT NULL,
    "testId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: SubjectChapter; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."SubjectChapter" (
    id integer NOT NULL,
    "subjectId" integer,
    "chapterId" integer,
    deleted boolean DEFAULT false,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TestQuestion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."TestQuestion" (
    id integer NOT NULL,
    "testId" integer NOT NULL,
    "questionId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "seqNum" integer DEFAULT 0 NOT NULL
);


--
-- Name: ChapterTestQuestion; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."ChapterTestQuestion" AS
 SELECT "Topic".id AS "chapterId",
    "Question".id AS "questionId"
   FROM (((RubyActiveAdmin_test."Topic"
     JOIN ( SELECT ct."chapterId",
            ct."testId"
           FROM ( SELECT "ChapterTest"."chapterId",
                    "ChapterTest"."testId",
                    count(*) OVER (PARTITION BY "ChapterTest"."testId") AS "countChapter"
                   FROM RubyActiveAdmin_test."ChapterTest",
                    RubyActiveAdmin_test."SubjectChapter"
                  WHERE (("ChapterTest"."chapterId" = "SubjectChapter"."chapterId") AND ("SubjectChapter"."subjectId" = ANY (ARRAY[53, 54, 55, 56])))) ct
          WHERE (ct."countChapter" = 1)) ct1 ON ((ct1."chapterId" = "Topic".id)))
     JOIN RubyActiveAdmin_test."TestQuestion" ON (("TestQuestion"."testId" = ct1."testId")))
     JOIN RubyActiveAdmin_test."Question" ON (("Question".id = "TestQuestion"."questionId")));


--
-- Name: ChapterTest_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChapterTest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterTest_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChapterTest_id_seq" OWNED BY RubyActiveAdmin_test."ChapterTest".id;


--
-- Name: ChapterVideo; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterVideo" (
    id integer NOT NULL,
    "chapterId" integer NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ChapterVideo10012021; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChapterVideo10012021" (
    id integer,
    "chapterId" integer,
    "videoId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: Video; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Video" (
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
-- Name: ChapterVideoStat; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."ChapterVideoStat" AS
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
                   FROM RubyActiveAdmin_test."ChapterVideo",
                    RubyActiveAdmin_test."Video",
                    RubyActiveAdmin_test."SubjectChapter"
                  WHERE (("ChapterVideo"."chapterId" = "SubjectChapter"."chapterId") AND ("SubjectChapter"."subjectId" = ANY (ARRAY[53, 54, 55, 56])) AND ("ChapterVideo"."videoId" = "Video".id) AND ((("Video".language)::text = 'hinglish'::text) OR ("SubjectChapter"."chapterId" = ANY (ARRAY[639, 640]))))
                  GROUP BY "ChapterVideo"."chapterId") "ChapterVideoStatData") "ChapterVideoStatDataWithId"
  WITH NO DATA;


--
-- Name: ChapterVideo_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChapterVideo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChapterVideo_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChapterVideo_id_seq" OWNED BY RubyActiveAdmin_test."ChapterVideo".id;


--
-- Name: ChatAnswer; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ChatAnswer" (
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
-- Name: ChatAnswer_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ChatAnswer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChatAnswer_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ChatAnswer_id_seq" OWNED BY RubyActiveAdmin_test."ChatAnswer".id;


--
-- Name: Comment; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Comment" (
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
-- Name: Comment_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Comment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Comment_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Comment_id_seq" OWNED BY RubyActiveAdmin_test."Comment".id;


--
-- Name: Constant; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Constant" (
    id integer NOT NULL,
    key text NOT NULL,
    value jsonb NOT NULL
);


--
-- Name: CommonLeaderBoard; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."CommonLeaderBoard" AS
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
                               FROM RubyActiveAdmin_test."Constant"
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
                   FROM RubyActiveAdmin_test."Question",
                    RubyActiveAdmin_test."Answer",
                    RubyActiveAdmin_test."User"
                  WHERE (("User".id = "Answer"."userId") AND ("Question".id = "Answer"."questionId"))
                  GROUP BY "User".id) "CommonLeaderBoardData"
          WHERE (("CommonLeaderBoardData"."correctAnswerCount" <> 0) AND ("CommonLeaderBoardData"."incorrectAnswerCount" <> 0) AND ("CommonLeaderBoardData"."recentAnswerCount" > 0))) "CommonLeaderBoardDatarank"
  WITH NO DATA;


--
-- Name: ConfigValue; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ConfigValue" (
    id integer NOT NULL,
    "accessToken" text,
    "refreshToken" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ConfigValue_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ConfigValue_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ConfigValue_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ConfigValue_id_seq" OWNED BY RubyActiveAdmin_test."ConfigValue".id;


--
-- Name: Constant_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Constant_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Constant_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Constant_id_seq" OWNED BY RubyActiveAdmin_test."Constant".id;


--
-- Name: CopyAnswer; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyAnswer" (
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
-- Name: CopyAnswer_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CopyAnswer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CopyAnswer_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CopyAnswer_id_seq" OWNED BY RubyActiveAdmin_test."CopyAnswer".id;


--
-- Name: CopyChapterFlashCard20201111; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyChapterFlashCard20201111" (
    id bigint,
    "chapterId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer,
    "seqId" integer
);


--
-- Name: CopyCourse; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyCourse" (
    id integer,
    name character varying(255),
    image text,
    description text,
    package RubyActiveAdmin_test."enum_Course_package",
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    fee numeric(10,2),
    RubyActiveAdmin_test boolean,
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
-- Name: CopyCourseTest20200916; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyCourseTest20200916" (
    id integer,
    "courseId" integer,
    "testId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: CopyNote; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyNote" (
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
-- Name: CopyQuestion01012019; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyQuestion01012019" (
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
    type RubyActiveAdmin_test."enum_Question_type"
);


--
-- Name: CopyQuestion010120191; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyQuestion010120191" (
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
    type RubyActiveAdmin_test."enum_Question_type"
);


--
-- Name: CopyQuestion20200504; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyQuestion20200504" (
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
    type RubyActiveAdmin_test."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level RubyActiveAdmin_test."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer
);


--
-- Name: CopyQuestion20201231; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyQuestion20201231" (
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
    type RubyActiveAdmin_test."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level RubyActiveAdmin_test."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer
);


--
-- Name: CopyQuestion23092020; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyQuestion23092020" (
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
    type RubyActiveAdmin_test."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level RubyActiveAdmin_test."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer
);


--
-- Name: CopyQuestion29092018; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyQuestion29092018" (
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
    type RubyActiveAdmin_test."enum_Question_type"
);


--
-- Name: CopyQuestionTranslation; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyQuestionTranslation" (
    id integer,
    "questionId" integer,
    question text,
    explanation text,
    language character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: CopyQuestionTranslation1; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyQuestionTranslation1" (
    id integer,
    "questionId" integer,
    question text,
    explanation text,
    language character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: CopySubjectChapter; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopySubjectChapter" (
    id integer,
    "subjectId" integer,
    "chapterId" integer,
    deleted boolean,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: CopyTarget20201111; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyTarget20201111" (
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
-- Name: CopyTestAttempt; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyTestAttempt" (
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
-- Name: CopyTestAttempt_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CopyTestAttempt_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CopyTestAttempt_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CopyTestAttempt_id_seq" OWNED BY RubyActiveAdmin_test."CopyTestAttempt".id;


--
-- Name: CopyTopic20200917; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CopyTopic20200917" (
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
-- Name: VideoQuestion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."VideoQuestion" (
    id integer NOT NULL,
    "videoId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "timestamp" integer
);


--
-- Name: CorrectAnswerVideo; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."CorrectAnswerVideo" AS
 SELECT row_number() OVER (ORDER BY "Answer".id, "Video".id) AS id,
    "Question".id AS "questionId",
    "Answer"."userId",
    "Video".id AS "videoId",
    "Answer"."testAttemptId",
    "Answer".id AS "answerId"
   FROM (((RubyActiveAdmin_test."Question"
     JOIN RubyActiveAdmin_test."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question"."correctOptionIndex" = "Answer"."userAnswer"))))
     JOIN RubyActiveAdmin_test."VideoQuestion" ON (("VideoQuestion"."questionId" = "Question".id)))
     JOIN RubyActiveAdmin_test."Video" ON (("Video".id = "VideoQuestion"."videoId")));


--
-- Name: Coupon; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Coupon" (
    id integer,
    code character varying(255),
    description text,
    quantity integer DEFAULT '-1'::integer NOT NULL,
    discount numeric(10,2) DEFAULT 0 NOT NULL,
    "discountType" RubyActiveAdmin_test."enum_Coupon_discountType" DEFAULT 'absolute'::RubyActiveAdmin_test."enum_Coupon_discountType"
);


--
-- Name: Course; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Course" (
    id integer NOT NULL,
    name character varying(255),
    image text,
    description text,
    package RubyActiveAdmin_test."enum_Course_package" DEFAULT 'k12'::RubyActiveAdmin_test."enum_Course_package",
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fee numeric(10,2) DEFAULT 0 NOT NULL,
    RubyActiveAdmin_test boolean DEFAULT false NOT NULL,
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
    "feeDesc" text
);


--
-- Name: Subject; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Subject" (
    id integer NOT NULL,
    name character varying(255),
    image text,
    description text,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "courseId" integer
);


--
-- Name: CourseChapter; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."CourseChapter" AS
 SELECT "Subject"."courseId",
    "SubjectChapter"."chapterId",
    "SubjectChapter"."subjectId"
   FROM RubyActiveAdmin_test."Subject",
    RubyActiveAdmin_test."SubjectChapter"
  WHERE ("SubjectChapter"."subjectId" = "Subject".id);


--
-- Name: CourseDetail; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CourseDetail" (
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
-- Name: CourseDetail_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CourseDetail_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseDetail_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CourseDetail_id_seq" OWNED BY RubyActiveAdmin_test."CourseDetail".id;


--
-- Name: CourseInvitation; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CourseInvitation" (
    id integer NOT NULL,
    "courseId" integer NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(255),
    "expiryAt" timestamp with time zone NOT NULL,
    role RubyActiveAdmin_test."enum_CourseInvitation_role" DEFAULT 'courseStudent'::RubyActiveAdmin_test."enum_CourseInvitation_role" NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "displayName" character varying(100),
    "creatorId" integer,
    "paymentId" integer,
    admin_user_id integer
);


--
-- Name: CourseInvitation_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CourseInvitation_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseInvitation_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CourseInvitation_id_seq" OWNED BY RubyActiveAdmin_test."CourseInvitation".id;


--
-- Name: CourseOffer; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CourseOffer" (
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
-- Name: CourseOffer_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CourseOffer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseOffer_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CourseOffer_id_seq" OWNED BY RubyActiveAdmin_test."CourseOffer".id;


--
-- Name: CourseQuestion; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."CourseQuestion" AS
 SELECT "Subject"."courseId",
    "Subject".id AS "subjectId",
    "SubjectChapter"."chapterId",
    "ChapterQuestion"."questionId"
   FROM RubyActiveAdmin_test."Subject",
    RubyActiveAdmin_test."SubjectChapter",
    RubyActiveAdmin_test."ChapterQuestion",
    RubyActiveAdmin_test."Question"
  WHERE (("SubjectChapter"."subjectId" = "Subject".id) AND ("SubjectChapter"."chapterId" = "ChapterQuestion"."chapterId") AND ("ChapterQuestion"."questionId" = "Question".id) AND ("Question".deleted = false));


--
-- Name: CourseTest; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CourseTest" (
    id integer NOT NULL,
    "courseId" integer NOT NULL,
    "testId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: CourseTestQuestion; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."CourseTestQuestion" AS
 SELECT "CourseTest"."courseId",
    "TestQuestion"."questionId",
    "Question"."topicId" AS "chapterId",
    "Question"."subjectId"
   FROM RubyActiveAdmin_test."CourseTest",
    RubyActiveAdmin_test."TestQuestion",
    RubyActiveAdmin_test."Question"
  WHERE (("CourseTest"."testId" = "TestQuestion"."testId") AND ("TestQuestion"."questionId" = "Question".id) AND ("Question".deleted = false));


--
-- Name: CourseTest_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CourseTest_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseTest_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CourseTest_id_seq" OWNED BY RubyActiveAdmin_test."CourseTest".id;


--
-- Name: CourseTestimonial; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CourseTestimonial" (
    id integer NOT NULL,
    "courseId" integer NOT NULL,
    content text NOT NULL,
    author character varying(255) NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: CourseTestimonial_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CourseTestimonial_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CourseTestimonial_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CourseTestimonial_id_seq" OWNED BY RubyActiveAdmin_test."CourseTestimonial".id;


--
-- Name: Course_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Course_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Course_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Course_id_seq" OWNED BY RubyActiveAdmin_test."Course".id;


--
-- Name: CustomerIssue; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CustomerIssue" (
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
    "flashCardId" integer
);


--
-- Name: CustomerIssue20201120; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CustomerIssue20201120" (
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
-- Name: CustomerIssueType; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CustomerIssueType" (
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
-- Name: CustomerIssueType_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CustomerIssueType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CustomerIssueType_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CustomerIssueType_id_seq" OWNED BY RubyActiveAdmin_test."CustomerIssueType".id;


--
-- Name: CustomerIssue_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CustomerIssue_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CustomerIssue_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CustomerIssue_id_seq" OWNED BY RubyActiveAdmin_test."CustomerIssue".id;


--
-- Name: CustomerSupport; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."CustomerSupport" (
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
-- Name: CustomerSupport_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."CustomerSupport_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CustomerSupport_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."CustomerSupport_id_seq" OWNED BY RubyActiveAdmin_test."CustomerSupport".id;


--
-- Name: DailyUserEvent; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."DailyUserEvent" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "eventDate" date NOT NULL,
    event character varying(25) NOT NULL,
    "eventCount" integer NOT NULL,
    "courseId" integer
);


--
-- Name: DailyUserEvent_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."DailyUserEvent_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DailyUserEvent_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."DailyUserEvent_id_seq" OWNED BY RubyActiveAdmin_test."DailyUserEvent".id;


--
-- Name: Delivery; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Delivery" (
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
-- Name: Delivery_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Delivery_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Delivery_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Delivery_id_seq" OWNED BY RubyActiveAdmin_test."Delivery".id;


--
-- Name: Doubt; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Doubt" (
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
    "doubtType" RubyActiveAdmin_test."enum_Doubt_doubtType",
    "goodFlag" boolean DEFAULT false,
    "audioLink" character varying,
    "voteCount" integer DEFAULT 0,
    "doubtSolved" boolean DEFAULT false
);


--
-- Name: DoubtAnswer; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."DoubtAnswer" (
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
-- Name: DoubtAnswer_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."DoubtAnswer_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DoubtAnswer_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."DoubtAnswer_id_seq" OWNED BY RubyActiveAdmin_test."DoubtAnswer".id;


--
-- Name: Doubt_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Doubt_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Doubt_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Doubt_id_seq" OWNED BY RubyActiveAdmin_test."Doubt".id;


--
-- Name: DuplicateChapter; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."DuplicateChapter" (
    id integer NOT NULL,
    "origId" integer NOT NULL,
    "dupId" integer NOT NULL
);


--
-- Name: DuplicateChapter_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."DuplicateChapter_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DuplicateChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."DuplicateChapter_id_seq" OWNED BY RubyActiveAdmin_test."DuplicateChapter".id;


--
-- Name: DuplicatePost; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."DuplicatePost" (
    id integer NOT NULL,
    "postId" integer NOT NULL,
    content text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: DuplicatePost_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."DuplicatePost_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DuplicatePost_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."DuplicatePost_id_seq" OWNED BY RubyActiveAdmin_test."DuplicatePost".id;


--
-- Name: DuplicateQuestion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."DuplicateQuestion" (
    id integer NOT NULL,
    "questionId1" integer NOT NULL,
    "questionId2" integer NOT NULL
);


--
-- Name: DuplicateQuestion20200710; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."DuplicateQuestion20200710" (
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
    type RubyActiveAdmin_test."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level RubyActiveAdmin_test."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer
);


--
-- Name: DuplicateQuestion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."DuplicateQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DuplicateQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."DuplicateQuestion_id_seq" OWNED BY RubyActiveAdmin_test."DuplicateQuestion".id;


--
-- Name: ExamQuestion; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."ExamQuestion" AS
 SELECT "Question".id,
    "Question".deleted
   FROM RubyActiveAdmin_test."Question"
  WHERE (EXISTS ( SELECT 1
           FROM RubyActiveAdmin_test."QuestionDetail"
          WHERE (("Question".id = "QuestionDetail"."questionId") AND ((("QuestionDetail".exam)::text <> 'BOARD'::text) OR ("QuestionDetail".exam IS NULL)))));


--
-- Name: FcmToken; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."FcmToken" (
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
-- Name: FcmToken_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."FcmToken_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: FcmToken_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."FcmToken_id_seq" OWNED BY RubyActiveAdmin_test."FcmToken".id;


--
-- Name: FestivalDiscount; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."FestivalDiscount" (
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
-- Name: FestivalDiscount_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."FestivalDiscount_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: FestivalDiscount_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."FestivalDiscount_id_seq" OWNED BY RubyActiveAdmin_test."FestivalDiscount".id;


--
-- Name: FlashCard; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."FlashCard" (
    id bigint NOT NULL,
    content character varying,
    title character varying,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- Name: FlashCard20200609; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."FlashCard20200609" (
    id bigint,
    content character varying,
    title character varying,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);


--
-- Name: FlashCard_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."FlashCard_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: FlashCard_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."FlashCard_id_seq" OWNED BY RubyActiveAdmin_test."FlashCard".id;


--
-- Name: Glossary; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Glossary" (
    id bigint NOT NULL,
    word character varying,
    translation character varying,
    language character varying,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- Name: Glossary_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Glossary_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Glossary_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Glossary_id_seq" OWNED BY RubyActiveAdmin_test."Glossary".id;


--
-- Name: Group; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Group" (
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
-- Name: Group_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Group_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Group_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Group_id_seq" OWNED BY RubyActiveAdmin_test."Group".id;


--
-- Name: IncorrectAnswerVideo; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."IncorrectAnswerVideo" AS
 SELECT row_number() OVER (ORDER BY "Answer".id, "Video".id) AS id,
    "Answer"."testAttemptId",
    "Question".id AS "questionId",
    "Answer"."userId",
    "Video".id AS "videoId",
    "Answer".id AS "answerId"
   FROM (((RubyActiveAdmin_test."Question"
     JOIN RubyActiveAdmin_test."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question"."correctOptionIndex" <> "Answer"."userAnswer"))))
     JOIN RubyActiveAdmin_test."VideoQuestion" ON (("VideoQuestion"."questionId" = "Question".id)))
     JOIN RubyActiveAdmin_test."Video" ON (("Video".id = "VideoQuestion"."videoId")));


--
-- Name: Installment; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Installment" (
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
-- Name: Installment_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Installment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Installment_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Installment_id_seq" OWNED BY RubyActiveAdmin_test."Installment".id;


--
-- Name: MasterClassFreeUser; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."MasterClassFreeUser" (
    "userId" integer,
    total_count bigint
);


--
-- Name: Message; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Message" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "groupId" integer NOT NULL,
    content character varying(255),
    type RubyActiveAdmin_test."enum_Message_type" DEFAULT 'normal'::RubyActiveAdmin_test."enum_Message_type",
    deleted boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "questionId" integer
);


--
-- Name: Message_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Message_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Message_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Message_id_seq" OWNED BY RubyActiveAdmin_test."Message".id;


--
-- Name: Motivation; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Motivation" (
    id integer NOT NULL,
    message text NOT NULL,
    author character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Motivation_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Motivation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Motivation_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Motivation_id_seq" OWNED BY RubyActiveAdmin_test."Motivation".id;


--
-- Name: NCERTQuestion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."NCERTQuestion" (
    id integer NOT NULL,
    "questionId" integer
);


--
-- Name: NCERTQuestion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."NCERTQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NCERTQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."NCERTQuestion_id_seq" OWNED BY RubyActiveAdmin_test."NCERTQuestion".id;


--
-- Name: NEETExamResult; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."NEETExamResult" (
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
-- Name: NEETExamResult_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."NEETExamResult_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NEETExamResult_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."NEETExamResult_id_seq" OWNED BY RubyActiveAdmin_test."NEETExamResult".id;


--
-- Name: NewUserVideoStat; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."NewUserVideoStat" (
    id integer,
    "userId" integer,
    "videoId" integer,
    "lastPosition" double precision,
    completed boolean,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: NksAppVersion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."NksAppVersion" (
    id integer NOT NULL,
    name character varying(255),
    version character varying(255),
    description text,
    "forceUpdate" boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: NksAppVersion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."NksAppVersion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NksAppVersion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."NksAppVersion_id_seq" OWNED BY RubyActiveAdmin_test."NksAppVersion".id;


--
-- Name: NotDuplicateQuestion; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."NotDuplicateQuestion" (
    "questionId1" integer NOT NULL,
    "questionId2" integer NOT NULL,
    id integer NOT NULL,
    CONSTRAINT "DuplicateQuestion_questionId1_less_than_questionId2" CHECK (("questionId1" < "questionId2")),
    CONSTRAINT "NotDuplicateQuestion_questionId1_less_than_questionId2" CHECK (("questionId1" < "questionId2"))
);


--
-- Name: NotDuplicateQuestion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."NotDuplicateQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NotDuplicateQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."NotDuplicateQuestion_id_seq" OWNED BY RubyActiveAdmin_test."NotDuplicateQuestion".id;


--
-- Name: Note; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Note" (
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
-- Name: Note03112020; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Note03112020" (
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
-- Name: Note20201026; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Note20201026" (
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
-- Name: Note_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Note_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Note_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Note_id_seq" OWNED BY RubyActiveAdmin_test."Note".id;


--
-- Name: Notification; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Notification" (
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
-- Name: Notification_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Notification_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Notification_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Notification_id_seq" OWNED BY RubyActiveAdmin_test."Notification".id;


--
-- Name: OldCourseTest; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."OldCourseTest" (
    id integer NOT NULL,
    "courseId" integer,
    "testId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: OldCourseTest_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."OldCourseTest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: OldCourseTest_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."OldCourseTest_id_seq" OWNED BY RubyActiveAdmin_test."OldCourseTest".id;


--
-- Name: Payment; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Payment" (
    id integer NOT NULL,
    request json,
    response json,
    status RubyActiveAdmin_test."enum_Payment_status" DEFAULT 'created'::RubyActiveAdmin_test."enum_Payment_status",
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
-- Name: PaymentCourseInvitation; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."PaymentCourseInvitation" (
    id integer NOT NULL,
    "paymentId" integer NOT NULL,
    "courseInvitationId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: PaymentCourseInvitation_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."PaymentCourseInvitation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PaymentCourseInvitation_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."PaymentCourseInvitation_id_seq" OWNED BY RubyActiveAdmin_test."PaymentCourseInvitation".id;


--
-- Name: Payment_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Payment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Payment_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Payment_id_seq" OWNED BY RubyActiveAdmin_test."Payment".id;


--
-- Name: Post; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Post" (
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
-- Name: Post_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Post_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Post_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Post_id_seq" OWNED BY RubyActiveAdmin_test."Post".id;


--
-- Name: Question20200516; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Question20200516" (
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
    type RubyActiveAdmin_test."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level RubyActiveAdmin_test."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer
);


--
-- Name: Question20201305; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Question20201305" (
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
    type RubyActiveAdmin_test."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level RubyActiveAdmin_test."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer
);


--
-- Name: Question20203011; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Question20203011" (
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
    type RubyActiveAdmin_test."enum_Question_type",
    "paidAccess" boolean,
    "explanationMp4" text,
    level RubyActiveAdmin_test."enum_Question_level",
    jee boolean,
    "sequenceId" integer,
    "proofRead" boolean,
    "orignalQuestionId" integer,
    "topicId" integer,
    "subjectId" integer,
    lock_version integer
);


--
-- Name: QuestionCopy; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."QuestionCopy" AS
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
   FROM RubyActiveAdmin_test."CopyQuestion29092018";


--
-- Name: QuestionCourse; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."QuestionCourse" (
    "questionId" integer NOT NULL,
    "courseId" integer NOT NULL
);


--
-- Name: QuestionDetail_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."QuestionDetail_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionDetail_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."QuestionDetail_id_seq" OWNED BY RubyActiveAdmin_test."QuestionDetail".id;


--
-- Name: QuestionExplanation; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."QuestionExplanation" (
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
-- Name: QuestionExplanation20200516; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."QuestionExplanation20200516" (
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
-- Name: QuestionExplanation_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."QuestionExplanation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionExplanation_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."QuestionExplanation_id_seq" OWNED BY RubyActiveAdmin_test."QuestionExplanation".id;


--
-- Name: QuestionHint; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."QuestionHint" (
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
-- Name: QuestionHint_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."QuestionHint_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionHint_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."QuestionHint_id_seq" OWNED BY RubyActiveAdmin_test."QuestionHint".id;


--
-- Name: QuestionSubTopic; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."QuestionSubTopic" (
    id integer NOT NULL,
    "questionId" integer,
    "subTopicId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: QuestionSubTopic_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."QuestionSubTopic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionSubTopic_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."QuestionSubTopic_id_seq" OWNED BY RubyActiveAdmin_test."QuestionSubTopic".id;


--
-- Name: QuestionTranslation; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."QuestionTranslation" (
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
-- Name: QuestionTranslation20201119; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."QuestionTranslation20201119" (
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
-- Name: QuestionTranslation_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."QuestionTranslation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuestionTranslation_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."QuestionTranslation_id_seq" OWNED BY RubyActiveAdmin_test."QuestionTranslation".id;


--
-- Name: Question_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Question_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Question_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Question_id_seq" OWNED BY RubyActiveAdmin_test."Question".id;


--
-- Name: Quiz; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Quiz" (
    id integer NOT NULL,
    name character varying(255),
    description text,
    "timeRequiredInSeconds" integer,
    "creatorId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Quiz_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Quiz_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Quiz_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Quiz_id_seq" OWNED BY RubyActiveAdmin_test."Quiz".id;


--
-- Name: SEOData; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."SEOData" (
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
-- Name: SEOData_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."SEOData_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SEOData_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."SEOData_id_seq" OWNED BY RubyActiveAdmin_test."SEOData".id;


--
-- Name: Schedule; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Schedule" (
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    name text,
    description text,
    "isActive" boolean
);


--
-- Name: ScheduleItem; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ScheduleItem" (
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
-- Name: ScheduleItemAsset; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ScheduleItemAsset" (
    id bigint NOT NULL,
    "ScheduleItem_id" bigint,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "assetLink" text,
    "assetName" character varying
);


--
-- Name: ScheduleItemAssetBak; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ScheduleItemAssetBak" (
    id bigint,
    "ScheduleItem_id" bigint,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "assetLink" text,
    "assetName" character varying
);


--
-- Name: ScheduleItemAsset_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ScheduleItemAsset_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ScheduleItemAsset_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ScheduleItemAsset_id_seq" OWNED BY RubyActiveAdmin_test."ScheduleItemAsset".id;


--
-- Name: ScheduleItemBak; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ScheduleItemBak" (
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
-- Name: ScheduleItemUser; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ScheduleItemUser" (
    id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "scheduleItemId" integer NOT NULL,
    "userId" integer NOT NULL,
    completed boolean
);


--
-- Name: ScheduleItemUser_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ScheduleItemUser_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ScheduleItemUser_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ScheduleItemUser_id_seq" OWNED BY RubyActiveAdmin_test."ScheduleItemUser".id;


--
-- Name: ScheduleItem_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ScheduleItem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ScheduleItem_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ScheduleItem_id_seq" OWNED BY RubyActiveAdmin_test."ScheduleItem".id;


--
-- Name: Schedule_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Schedule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Schedule_id_seq" OWNED BY RubyActiveAdmin_test."Schedule".id;


--
-- Name: ScheduledTask; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."ScheduledTask" (
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
-- Name: ScheduledTask_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."ScheduledTask_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ScheduledTask_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."ScheduledTask_id_seq" OWNED BY RubyActiveAdmin_test."ScheduledTask".id;


--
-- Name: Section; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Section" (
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
-- Name: SectionContent; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."SectionContent" (
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
-- Name: SectionContent_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."SectionContent_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SectionContent_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."SectionContent_id_seq" OWNED BY RubyActiveAdmin_test."SectionContent".id;


--
-- Name: Section_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Section_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Section_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Section_id_seq" OWNED BY RubyActiveAdmin_test."Section".id;


--
-- Name: SequelizeMeta; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."SequelizeMeta" (
    name character varying(255) NOT NULL
);


--
-- Name: StudentNote; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."StudentNote" (
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
    "videoId" integer
);


--
-- Name: StudentNote_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."StudentNote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: StudentNote_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."StudentNote_id_seq" OWNED BY RubyActiveAdmin_test."StudentNote".id;


--
-- Name: StudentOnboardingEvents; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."StudentOnboardingEvents" (
    id bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "userId" integer,
    description character varying
);


--
-- Name: StudentOnboardingEvents_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."StudentOnboardingEvents_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: StudentOnboardingEvents_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."StudentOnboardingEvents_id_seq" OWNED BY RubyActiveAdmin_test."StudentOnboardingEvents".id;


--
-- Name: SubTopic; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."SubTopic" (
    id integer NOT NULL,
    "topicId" integer,
    name character varying(255),
    deleted boolean DEFAULT false,
    "position" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: SubTopic_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."SubTopic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SubTopic_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."SubTopic_id_seq" OWNED BY RubyActiveAdmin_test."SubTopic".id;


--
-- Name: SubjectChapter_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."SubjectChapter_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SubjectChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."SubjectChapter_id_seq" OWNED BY RubyActiveAdmin_test."SubjectChapter".id;


--
-- Name: TopicQuestion; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."TopicQuestion" AS
 SELECT "Question".id,
    "ChapterQuestion"."chapterId" AS "topicId"
   FROM RubyActiveAdmin_test."Question",
    RubyActiveAdmin_test."ChapterQuestion"
  WHERE (("Question".deleted = false) AND ("Question".id = "ChapterQuestion"."questionId"));


--
-- Name: SubjectLeaderBoard; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."SubjectLeaderBoard" AS
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
                           FROM RubyActiveAdmin_test."Question",
                            RubyActiveAdmin_test."TopicQuestion",
                            RubyActiveAdmin_test."Topic",
                            RubyActiveAdmin_test."Subject",
                            RubyActiveAdmin_test."Answer",
                            RubyActiveAdmin_test."User"
                          WHERE (("User".id = "Answer"."userId") AND ("Question".id = "Answer"."questionId") AND ("TopicQuestion".id = "Answer"."questionId") AND ("Question".deleted = false) AND ("TopicQuestion"."topicId" = "Topic".id) AND ("Topic"."subjectId" = "Subject".id) AND ("Subject"."courseId" = 8))
                          GROUP BY "Subject".id, "User".id) subjectleaderboarddata
                  WHERE (subjectleaderboarddata."correctAnswerCount" <> 0)) "SubjectLeaderboardTable") "SubjectLeaderboardTableData"
  WITH NO DATA;


--
-- Name: Subject_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Subject_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Subject_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Subject_id_seq" OWNED BY RubyActiveAdmin_test."Subject".id;


--
-- Name: Target; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Target" (
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
-- Name: TargetChapter; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."TargetChapter" (
    id bigint NOT NULL,
    "chapterId" integer NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "targetId" integer NOT NULL,
    hours integer NOT NULL,
    revision boolean DEFAULT false
);


--
-- Name: TargetChapter_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."TargetChapter_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TargetChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."TargetChapter_id_seq" OWNED BY RubyActiveAdmin_test."TargetChapter".id;


--
-- Name: Target_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Target_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Target_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Target_id_seq" OWNED BY RubyActiveAdmin_test."Target".id;


--
-- Name: Task; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Task" (
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
-- Name: Task_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Task_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Task_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Task_id_seq" OWNED BY RubyActiveAdmin_test."Task".id;


--
-- Name: Test; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Test" (
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
    exam RubyActiveAdmin_test."enum_Test_exam",
    "pdfURL" text,
    "userId" integer,
    scholarship boolean DEFAULT false NOT NULL,
    "reviewAt" timestamp with time zone,
    "discussionEnd" timestamp with time zone
);


--
-- Name: TestAttempt; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."TestAttempt" (
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
-- Name: TestAttemptBackup506173; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."TestAttemptBackup506173" (
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
-- Name: TestAttemptDetail; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."TestAttemptDetail" AS
 SELECT "TestAttempt".id,
    RubyActiveAdmin_test."TestAttemptDetailFunc"("TestAttempt".id) AS "showAnswer"
   FROM RubyActiveAdmin_test."TestAttempt"
  WHERE ("TestAttempt".completed = true);


--
-- Name: TestAttemptHistory; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."TestAttemptHistory" (
    "eventTime" timestamp(2) without time zone,
    "userId" integer,
    "testId" integer,
    "changedAnswers" jsonb
);


--
-- Name: TestAttemptPostmartem; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."TestAttemptPostmartem" (
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
-- Name: TestAttemptPostmartem_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."TestAttemptPostmartem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TestAttemptPostmartem_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."TestAttemptPostmartem_id_seq" OWNED BY RubyActiveAdmin_test."TestAttemptPostmartem".id;


--
-- Name: TestAttempt_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."TestAttempt_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TestAttempt_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."TestAttempt_id_seq" OWNED BY RubyActiveAdmin_test."TestAttempt".id;


--
-- Name: TestQuestion20201130; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."TestQuestion20201130" (
    id integer,
    "testId" integer,
    "questionId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "seqNum" integer
);


--
-- Name: TestQuestion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."TestQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TestQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."TestQuestion_id_seq" OWNED BY RubyActiveAdmin_test."TestQuestion".id;


--
-- Name: Test_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Test_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Test_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Test_id_seq" OWNED BY RubyActiveAdmin_test."Test".id;


--
-- Name: TopicAsset; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."TopicAsset" AS
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
           FROM RubyActiveAdmin_test."ChapterVideo",
            RubyActiveAdmin_test."SubjectChapter",
            RubyActiveAdmin_test."Subject",
            RubyActiveAdmin_test."Course"
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
           FROM RubyActiveAdmin_test."ChapterQuestion",
            RubyActiveAdmin_test."SubjectChapter",
            RubyActiveAdmin_test."Subject",
            RubyActiveAdmin_test."Course"
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
           FROM RubyActiveAdmin_test."ChapterNote",
            RubyActiveAdmin_test."SubjectChapter",
            RubyActiveAdmin_test."Subject",
            RubyActiveAdmin_test."Course"
          WHERE (("SubjectChapter"."chapterId" = "ChapterNote"."chapterId") AND ("SubjectChapter".deleted = false) AND ("SubjectChapter"."subjectId" = "Subject".id) AND ("Course".id = "Subject"."courseId") AND ("Course".id = 8))) "topicAsset";


--
-- Name: TopicAssetOld; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."TopicAssetOld" (
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
-- Name: TopicAsset_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."TopicAsset_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TopicAsset_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."TopicAsset_id_seq" OWNED BY RubyActiveAdmin_test."TopicAssetOld".id;


--
-- Name: TopicLeaderBoard; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."TopicLeaderBoard" AS
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
                           FROM RubyActiveAdmin_test."Question",
                            RubyActiveAdmin_test."Answer",
                            RubyActiveAdmin_test."User",
                            RubyActiveAdmin_test."TopicQuestion",
                            RubyActiveAdmin_test."Topic",
                            RubyActiveAdmin_test."Subject"
                          WHERE (("User".id = "Answer"."userId") AND ("Question".id = "Answer"."questionId") AND ("TopicQuestion".id = "Answer"."questionId") AND ("Question".deleted = false) AND ("TopicQuestion"."topicId" = "Topic".id) AND ("Topic"."subjectId" = "Subject".id) AND ("Subject"."courseId" = 8))
                          GROUP BY "User".id, "TopicQuestion"."topicId") "TopicLeaderBoardData"
                  WHERE (("TopicLeaderBoardData"."correctAnswerCount" <> 0) OR ("TopicLeaderBoardData"."incorrectAnswerCount" <> 0))) "TopicLeaderBoardDataRank") "TopicLeaderBoardDataWithRank"
  WITH NO DATA;


--
-- Name: Topic_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Topic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Topic_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Topic_id_seq" OWNED BY RubyActiveAdmin_test."Topic".id;


--
-- Name: UnattemptedQuestionVideo; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."UnattemptedQuestionVideo" AS
 SELECT row_number() OVER (ORDER BY "Answer".id, "Video".id) AS id,
    "Test".id AS "testId",
    "Question".id AS "questionId",
    "TestAttempt".id AS "testAttemptId",
    "TestAttempt"."userId",
    "Video".id AS "videoId"
   FROM RubyActiveAdmin_test."TestAttempt",
    RubyActiveAdmin_test."Test",
    RubyActiveAdmin_test."Question",
    RubyActiveAdmin_test."VideoQuestion",
    RubyActiveAdmin_test."Video",
    RubyActiveAdmin_test."Answer",
    RubyActiveAdmin_test."TestQuestion"
  WHERE (("Answer".id IS NULL) AND ("Test".id = "TestAttempt"."testId") AND ("VideoQuestion"."questionId" = "Question".id) AND ("Video".id = "VideoQuestion"."videoId") AND ("Question".id = "Answer"."questionId") AND ("Test".id = "TestQuestion"."testId"));


--
-- Name: admin_users; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.admin_users (
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
-- Name: UniqueDoubtAnswer; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."UniqueDoubtAnswer" AS
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
           FROM (RubyActiveAdmin_test."DoubtAnswer" d
             JOIN RubyActiveAdmin_test."Doubt" a ON ((d."doubtId" = a.id)))
          WHERE (d."userId" IN ( SELECT admin_users."userId"
                   FROM RubyActiveAdmin_test.admin_users
                  WHERE (((admin_users.role)::text = 'faculty'::text) OR ((admin_users.role)::text = 'superfaculty'::text))))) _event
  WHERE (_event.row_number = 1);


--
-- Name: UserCourse; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserCourse" (
    id integer NOT NULL,
    "startedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "expiryAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    role RubyActiveAdmin_test."enum_UserCourse_role" DEFAULT 'courseStudent'::RubyActiveAdmin_test."enum_UserCourse_role",
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "courseId" integer NOT NULL,
    "userId" integer,
    "couponId" integer,
    trial boolean DEFAULT false,
    "invitationId" integer,
    "courseOfferId" integer
);


--
-- Name: UserChapter; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."UserChapter" AS
 SELECT 1 AS id,
    "allChapters"."userId",
    "allChapters"."chapterId",
    "allChapters"."subjectId"
   FROM ( SELECT "User".id AS "userId",
            "Topic".id AS "chapterId",
            "Subject".id AS "subjectId"
           FROM RubyActiveAdmin_test."User",
            RubyActiveAdmin_test."UserCourse",
            RubyActiveAdmin_test."Subject",
            RubyActiveAdmin_test."Topic",
            RubyActiveAdmin_test."SubjectChapter"
          WHERE (("User".id = "UserCourse"."userId") AND ("UserCourse"."courseId" = "Subject"."courseId") AND ("Subject".id = "SubjectChapter"."subjectId") AND ("SubjectChapter"."chapterId" = "Topic".id) AND ("UserCourse"."expiryAt" >= now()) AND ("SubjectChapter".deleted = false) AND ("Topic".free <> true))
        UNION
         SELECT NULL::integer AS "userId",
            "Topic".id AS "chapterId",
            "Subject".id AS "subjectId"
           FROM RubyActiveAdmin_test."Subject",
            RubyActiveAdmin_test."Topic",
            RubyActiveAdmin_test."SubjectChapter"
          WHERE (("Topic".free = true) AND ("Subject".id = "SubjectChapter"."subjectId") AND ("SubjectChapter"."chapterId" = "Topic".id) AND ("SubjectChapter".deleted = false))) "allChapters";


--
-- Name: UserChapterStat; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserChapterStat" (
    id integer NOT NULL,
    "userId" integer,
    "chapterId" integer,
    completed boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: UserChapterStat_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserChapterStat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserChapterStat_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserChapterStat_id_seq" OWNED BY RubyActiveAdmin_test."UserChapterStat".id;


--
-- Name: UserClaim; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserClaim" (
    id integer NOT NULL,
    type character varying(255),
    value character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "userId" integer
);


--
-- Name: UserClaim_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserClaim_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserClaim_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserClaim_id_seq" OWNED BY RubyActiveAdmin_test."UserClaim".id;


--
-- Name: UserCourse177174; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserCourse177174" (
    id integer,
    "startedAt" timestamp with time zone,
    "expiryAt" timestamp with time zone,
    role RubyActiveAdmin_test."enum_UserCourse_role",
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
-- Name: UserCourse_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserCourse_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserCourse_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserCourse_id_seq" OWNED BY RubyActiveAdmin_test."UserCourse".id;


--
-- Name: UserDoubtStat; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."UserDoubtStat" AS
 SELECT "UserDoubtStatTemp".id,
    "UserDoubtStatTemp"."userId",
    "UserDoubtStatTemp"."doubtCount",
    COALESCE("UserDoubtStatTemp"."doubt7DaysCount", (0)::bigint) AS "doubt7DaysCount"
   FROM ( SELECT "User".id,
            "User".id AS "userId",
            doubt.doubt AS "doubtCount",
            doubt7."doubt7Count" AS "doubt7DaysCount"
           FROM ((RubyActiveAdmin_test."User"
             JOIN ( SELECT "Doubt"."userId" AS ausrid,
                    count(*) AS doubt
                   FROM RubyActiveAdmin_test."Doubt"
                  GROUP BY "Doubt"."userId") doubt ON (("User".id = doubt.ausrid)))
             LEFT JOIN ( SELECT "Doubt"."userId" AS aus7rid,
                    count(*) AS "doubt7Count"
                   FROM RubyActiveAdmin_test."Doubt"
                  WHERE ("Doubt"."createdAt" > (CURRENT_DATE - '7 days'::interval))
                  GROUP BY "Doubt"."userId") doubt7 ON (("User".id = doubt7.aus7rid)))) "UserDoubtStatTemp"
  WITH NO DATA;


--
-- Name: UserFlashCard; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserFlashCard" (
    id bigint NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "flashCardId" integer NOT NULL
);


--
-- Name: UserFlashCard20200611; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserFlashCard20200611" (
    id bigint,
    "userId" integer,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "flashCardId" integer
);


--
-- Name: UserFlashCard_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserFlashCard_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserFlashCard_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserFlashCard_id_seq" OWNED BY RubyActiveAdmin_test."UserFlashCard".id;


--
-- Name: UserHighlightedNote; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserHighlightedNote" (
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
-- Name: UserHighlightedNote_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserHighlightedNote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserHighlightedNote_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserHighlightedNote_id_seq" OWNED BY RubyActiveAdmin_test."UserHighlightedNote".id;


--
-- Name: UserLogin; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserLogin" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    expiry integer NOT NULL,
    platform character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: UserLogin_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserLogin_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserLogin_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserLogin_id_seq" OWNED BY RubyActiveAdmin_test."UserLogin".id;


--
-- Name: UserNoteStat; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserNoteStat" (
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
-- Name: UserNoteStat_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserNoteStat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserNoteStat_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserNoteStat_id_seq" OWNED BY RubyActiveAdmin_test."UserNoteStat".id;


--
-- Name: UserProfile; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserProfile" (
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
    "allowDeprecatedNcert" boolean DEFAULT false NOT NULL
);


--
-- Name: UserVideoStat; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserVideoStat" (
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
-- Name: UserProfileAnalytic; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."UserProfileAnalytic" AS
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
           FROM ((((((RubyActiveAdmin_test."User"
             LEFT JOIN ( SELECT "Answer"."userId" AS ausrid,
                    count("Answer"."userAnswer") AS ans
                   FROM RubyActiveAdmin_test."Answer"
                  GROUP BY "Answer"."userId") ans ON (("User".id = ans.ausrid)))
             LEFT JOIN ( SELECT "Answer"."userId" AS aus7rid,
                    count("Answer"."userAnswer") AS "ans7Count"
                   FROM RubyActiveAdmin_test."Answer"
                  WHERE ("Answer"."createdAt" > (CURRENT_DATE - '7 days'::interval))
                  GROUP BY "Answer"."userId") answer7 ON (("User".id = answer7.aus7rid)))
             LEFT JOIN ( SELECT "TestAttempt"."userId" AS usrid,
                    count("TestAttempt"."testId") AS "testId"
                   FROM RubyActiveAdmin_test."TestAttempt"
                  WHERE ("TestAttempt".completed = true)
                  GROUP BY "TestAttempt"."userId") testatp ON (("User".id = testatp.usrid)))
             LEFT JOIN ( SELECT "TestAttempt"."userId" AS usr7id,
                    count("TestAttempt"."testId") AS "test7Count"
                   FROM RubyActiveAdmin_test."TestAttempt"
                  WHERE (("TestAttempt".completed = true) AND ("TestAttempt"."createdAt" > (CURRENT_DATE - '7 days'::interval)))
                  GROUP BY "TestAttempt"."userId") test7atp ON (("User".id = test7atp.usr7id)))
             LEFT JOIN ( SELECT "UserVideoStat"."userId" AS vidusrid,
                    count("UserVideoStat"."videoId") AS vidid
                   FROM RubyActiveAdmin_test."UserVideoStat"
                  WHERE ("UserVideoStat".completed = true)
                  GROUP BY "UserVideoStat"."userId") "userV" ON (("User".id = "userV".vidusrid)))
             LEFT JOIN ( SELECT "UserVideoStat"."userId" AS vidusr7id,
                    count("UserVideoStat"."videoId") AS "vid7Count"
                   FROM RubyActiveAdmin_test."UserVideoStat"
                  WHERE (("UserVideoStat".completed = true) AND ("UserVideoStat"."createdAt" > (CURRENT_DATE - '7 days'::interval)))
                  GROUP BY "UserVideoStat"."userId") "user7V" ON (("User".id = "user7V".vidusr7id)))
          ORDER BY ans.ans, testatp."testId", "userV".vidid, answer7."ans7Count", test7atp."test7Count", "user7V"."vid7Count") "UserProfileAnalyticTable"
  WITH NO DATA;


--
-- Name: UserProfile_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserProfile_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserProfile_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserProfile_id_seq" OWNED BY RubyActiveAdmin_test."UserProfile".id;


--
-- Name: UserResult; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserResult" (
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
-- Name: UserResult_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserResult_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserResult_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserResult_id_seq" OWNED BY RubyActiveAdmin_test."UserResult".id;


--
-- Name: UserScheduledTask; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserScheduledTask" (
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
-- Name: UserScheduledTask_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserScheduledTask_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserScheduledTask_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserScheduledTask_id_seq" OWNED BY RubyActiveAdmin_test."UserScheduledTask".id;


--
-- Name: UserSectionStat; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserSectionStat" (
    id integer NOT NULL,
    "userId" integer,
    "sectionId" integer,
    completed boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: UserSectionStat_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserSectionStat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserSectionStat_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserSectionStat_id_seq" OWNED BY RubyActiveAdmin_test."UserSectionStat".id;


--
-- Name: UserTask; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserTask" (
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
-- Name: UserTaskProgress; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."UserTaskProgress" AS
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
                   FROM RubyActiveAdmin_test."ScheduleItemUser",
                    RubyActiveAdmin_test."ScheduleItem",
                    RubyActiveAdmin_test."Schedule"
                  WHERE (("ScheduleItemUser".completed = true) AND ("ScheduleItemUser"."scheduleItemId" = "ScheduleItem".id) AND ("Schedule".id = "ScheduleItem"."scheduleId") AND ("Schedule"."isActive" = true))
                  GROUP BY "ScheduleItemUser"."userId", "ScheduleItem"."scheduleId") "totalProgress",
            ( SELECT sum("ScheduleItem".hours) AS sum,
                    "ScheduleItem"."scheduleId"
                   FROM RubyActiveAdmin_test."ScheduleItem"
                  GROUP BY "ScheduleItem"."scheduleId") "totalDuration") "UserTaskProgressTable"
  WHERE ("UserTaskProgressTable"."userSchedule" = "UserTaskProgressTable"."scheduleId")
  WITH NO DATA;


--
-- Name: UserTask_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserTask_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserTask_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserTask_id_seq" OWNED BY RubyActiveAdmin_test."UserTask".id;


--
-- Name: UserTodo; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."UserTodo" (
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
-- Name: UserTodo_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserTodo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserTodo_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserTodo_id_seq" OWNED BY RubyActiveAdmin_test."UserTodo".id;


--
-- Name: UserVideo; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."UserVideo" AS
 SELECT 1 AS id,
    "allVideos"."userId",
    "allVideos"."topicId",
    "allVideos"."videoId"
   FROM ( SELECT "User".id AS "userId",
            "Topic".id AS "topicId",
            "ChapterVideo"."videoId"
           FROM RubyActiveAdmin_test."User",
            RubyActiveAdmin_test."UserCourse",
            RubyActiveAdmin_test."Subject",
            RubyActiveAdmin_test."Topic",
            RubyActiveAdmin_test."ChapterVideo",
            RubyActiveAdmin_test."SubjectChapter"
          WHERE (("User".id = "UserCourse"."userId") AND ("UserCourse"."courseId" = "Subject"."courseId") AND ("Subject".id = "SubjectChapter"."subjectId") AND ("SubjectChapter"."chapterId" = "Topic".id) AND ("ChapterVideo"."chapterId" = "Topic".id) AND ("UserCourse"."expiryAt" >= now()) AND ("SubjectChapter".deleted = false) AND ("Topic".free <> true))
        UNION
         SELECT NULL::integer AS "userId",
            "Topic".id AS "topicId",
            "ChapterVideo"."videoId"
           FROM RubyActiveAdmin_test."Subject",
            RubyActiveAdmin_test."Topic",
            RubyActiveAdmin_test."ChapterVideo"
          WHERE (("Topic".free = true) AND ("ChapterVideo"."chapterId" = "Topic".id))) "allVideos";


--
-- Name: UserVideoStat_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."UserVideoStat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserVideoStat_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."UserVideoStat_id_seq" OWNED BY RubyActiveAdmin_test."UserVideoStat".id;


--
-- Name: User_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."User_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."User_id_seq" OWNED BY RubyActiveAdmin_test."User".id;


--
-- Name: Video20200528; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Video20200528" (
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
-- Name: Video20200620; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Video20200620" (
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
-- Name: Video20201102; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Video20201102" (
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
-- Name: Video20201119; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Video20201119" (
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
-- Name: VideoAnnotation; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."VideoAnnotation" (
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
-- Name: VideoAnnotation_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."VideoAnnotation_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoAnnotation_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."VideoAnnotation_id_seq" OWNED BY RubyActiveAdmin_test."VideoAnnotation".id;


--
-- Name: VideoLink; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."VideoLink" (
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
-- Name: VideoLink_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."VideoLink_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoLink_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."VideoLink_id_seq" OWNED BY RubyActiveAdmin_test."VideoLink".id;


--
-- Name: VideoQuestion_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."VideoQuestion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."VideoQuestion_id_seq" OWNED BY RubyActiveAdmin_test."VideoQuestion".id;


--
-- Name: VideoSubTopic; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."VideoSubTopic" (
    id integer NOT NULL,
    "videoId" integer,
    "subTopicId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: VideoSubTopicQuestion; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test."VideoSubTopicQuestion" AS
SELECT
    NULL::integer AS id,
    NULL::integer AS "videoId",
    NULL::integer AS "questionId";


--
-- Name: VideoSubTopic_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."VideoSubTopic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoSubTopic_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."VideoSubTopic_id_seq" OWNED BY RubyActiveAdmin_test."VideoSubTopic".id;


--
-- Name: VideoTest; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."VideoTest" (
    id integer NOT NULL,
    "videoId" integer NOT NULL,
    "testId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: VideoTest_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."VideoTest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VideoTest_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."VideoTest_id_seq" OWNED BY RubyActiveAdmin_test."VideoTest".id;


--
-- Name: Video_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Video_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Video_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Video_id_seq" OWNED BY RubyActiveAdmin_test."Video".id;


--
-- Name: Vote; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test."Vote" (
    id integer NOT NULL,
    "userId" integer,
    "ownerId" integer,
    "ownerType" character varying(255),
    vote boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Vote_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test."Vote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Vote_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test."Vote_id_seq" OWNED BY RubyActiveAdmin_test."Vote".id;


--
-- Name: active_admin_comments; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.active_admin_comments (
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
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.active_admin_comments_id_seq OWNED BY RubyActiveAdmin_test.active_admin_comments.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.active_storage_attachments_id_seq OWNED BY RubyActiveAdmin_test.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.active_storage_blobs (
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
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.active_storage_blobs_id_seq OWNED BY RubyActiveAdmin_test.active_storage_blobs.id;


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.admin_users_id_seq OWNED BY RubyActiveAdmin_test.admin_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: coach_question_dashboard; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test.coach_question_dashboard AS
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
   FROM (((((RubyActiveAdmin_test."User"
     JOIN RubyActiveAdmin_test."Answer" ON (("Answer"."userId" = "User".id)))
     JOIN RubyActiveAdmin_test."Question" ON (("Question".id = "Answer"."questionId")))
     JOIN RubyActiveAdmin_test."ChapterQuestion" ON (("ChapterQuestion"."questionId" = "Question".id)))
     JOIN RubyActiveAdmin_test."Topic" ON (("Topic".id = "ChapterQuestion"."chapterId")))
     JOIN RubyActiveAdmin_test."Subject" ON (("Subject".id = "Topic"."subjectId")))
  WHERE (("Answer"."testAttemptId" IS NULL) AND ("Question".deleted = false));


--
-- Name: coach_video_dashboard; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test.coach_video_dashboard AS
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
   FROM (((((RubyActiveAdmin_test."User"
     JOIN RubyActiveAdmin_test."UserVideoStat" ON (("UserVideoStat"."userId" = "User".id)))
     JOIN RubyActiveAdmin_test."Video" ON (("Video".id = "UserVideoStat"."videoId")))
     JOIN RubyActiveAdmin_test."ChapterVideo" ON (("ChapterVideo"."videoId" = "Video".id)))
     JOIN RubyActiveAdmin_test."Topic" ON (("Topic".id = "ChapterVideo"."chapterId")))
     JOIN RubyActiveAdmin_test."Subject" ON (("Subject".id = "Topic"."subjectId")));


--
-- Name: copychaptervideo; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.copychaptervideo (
    id integer,
    "chapterId" integer,
    "videoId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: copyvideo; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.copyvideo (
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
-- Name: doubt_admins; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.doubt_admins (
    id bigint NOT NULL,
    "doubtId" integer,
    admin_user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: doubt_admins_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.doubt_admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doubt_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.doubt_admins_id_seq OWNED BY RubyActiveAdmin_test.doubt_admins.id;


--
-- Name: doubt_chat_channels; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.doubt_chat_channels (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: doubt_chat_channels_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.doubt_chat_channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doubt_chat_channels_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.doubt_chat_channels_id_seq OWNED BY RubyActiveAdmin_test.doubt_chat_channels.id;


--
-- Name: doubt_chat_doubt_answers; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.doubt_chat_doubt_answers (
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
-- Name: doubt_chat_doubt_answers_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.doubt_chat_doubt_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doubt_chat_doubt_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.doubt_chat_doubt_answers_id_seq OWNED BY RubyActiveAdmin_test.doubt_chat_doubt_answers.id;


--
-- Name: doubt_chat_doubts; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.doubt_chat_doubts (
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
-- Name: doubt_chat_doubts_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.doubt_chat_doubts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doubt_chat_doubts_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.doubt_chat_doubts_id_seq OWNED BY RubyActiveAdmin_test.doubt_chat_doubts.id;


--
-- Name: history; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.history (
    event_time timestamp(2) without time zone,
    executed_by text,
    origin_value jsonb,
    new_value jsonb
);


--
-- Name: note_details; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test.note_details AS
 SELECT "Note".id,
    "Note".id AS "noteId",
    "ChapterNote"."chapterId",
    "SubjectChapter"."subjectId" AS "SubjectId"
   FROM RubyActiveAdmin_test."Note",
    RubyActiveAdmin_test."ChapterNote",
    RubyActiveAdmin_test."SubjectChapter"
  WHERE (("Note".id = "ChapterNote"."noteId") AND ("SubjectChapter"."chapterId" = "ChapterNote"."chapterId") AND ("SubjectChapter"."subjectId" = ANY (ARRAY[53, 54, 55, 56])));


--
-- Name: schema_migrations; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: student_coaches; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.student_coaches (
    id bigint NOT NULL,
    "studentId" integer NOT NULL,
    "coachId" integer NOT NULL,
    role character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: student_coaches_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.student_coaches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: student_coaches_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.student_coaches_id_seq OWNED BY RubyActiveAdmin_test.student_coaches.id;


--
-- Name: test; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.test (
    a integer,
    b integer,
    c integer
);


--
-- Name: test_attempt_questions; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test.test_attempt_questions AS
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
   FROM ((((((((RubyActiveAdmin_test."TestAttempt"
     JOIN RubyActiveAdmin_test."Test" ON ((("Test".id = "TestAttempt"."testId") AND ("TestAttempt".completed = true))))
     JOIN RubyActiveAdmin_test."TestQuestion" ON (("TestQuestion"."testId" = "Test".id)))
     JOIN RubyActiveAdmin_test."Question" ON (("Question".id = "TestQuestion"."questionId")))
     LEFT JOIN RubyActiveAdmin_test."Answer" ON ((("TestAttempt".id = "Answer"."testAttemptId") AND ("Answer"."questionId" = "Question".id))))
     LEFT JOIN RubyActiveAdmin_test."TestAttemptPostmartem" ON ((("TestAttemptPostmartem"."testAttemptId" = "TestAttempt".id) AND ("TestAttemptPostmartem"."questionId" = "Question".id))))
     LEFT JOIN LATERAL ( SELECT "SubTopic".name
           FROM RubyActiveAdmin_test."QuestionSubTopic",
            RubyActiveAdmin_test."SubTopic"
          WHERE (("QuestionSubTopic"."questionId" = "Question".id) AND ("QuestionSubTopic"."subTopicId" = "SubTopic".id))
         LIMIT 1) "SubTopic1" ON (true))
     LEFT JOIN RubyActiveAdmin_test."Topic" ON (("Topic".id = "Question"."topicId")))
     LEFT JOIN RubyActiveAdmin_test."Subject" ON (("Subject".id = "Question"."subjectId")));


--
-- Name: user_actions; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.user_actions (
    id bigint NOT NULL,
    "userId" integer,
    count integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_actions_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.user_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.user_actions_id_seq OWNED BY RubyActiveAdmin_test.user_actions.id;


--
-- Name: usrs; Type: VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE VIEW RubyActiveAdmin_test.usrs AS
 SELECT "User".id,
    "UserProfile"."displayName" AS name,
    "User".email,
    "UserProfile".picture AS avatar,
    "User"."blockedUser" AS blocked
   FROM RubyActiveAdmin_test."User",
    RubyActiveAdmin_test."UserProfile"
  WHERE ("User".id = "UserProfile"."userId");


--
-- Name: version_associations; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.version_associations (
    id bigint NOT NULL,
    version_id integer,
    foreign_key_name character varying NOT NULL,
    foreign_key_id integer,
    foreign_type character varying
);


--
-- Name: version_associations_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.version_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.version_associations_id_seq OWNED BY RubyActiveAdmin_test.version_associations.id;


--
-- Name: versions; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.versions (
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
-- Name: versions_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.versions_id_seq OWNED BY RubyActiveAdmin_test.versions.id;


--
-- Name: votes; Type: TABLE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TABLE RubyActiveAdmin_test.votes (
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
-- Name: votes_id_seq; Type: SEQUENCE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE SEQUENCE RubyActiveAdmin_test.votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER SEQUENCE RubyActiveAdmin_test.votes_id_seq OWNED BY RubyActiveAdmin_test.votes.id;


--
-- Name: ActiveFlashCardChapter id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ActiveFlashCardChapter" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ActiveFlashCardChapter_id_seq"'::regclass);


--
-- Name: Advertisement id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Advertisement" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Advertisement_id_seq"'::regclass);


--
-- Name: Announcement id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Announcement" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Announcement_id_seq"'::regclass);


--
-- Name: Answer id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Answer" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Answer_id_seq"'::regclass);


--
-- Name: AppVersion id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."AppVersion" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."AppVersion_id_seq"'::regclass);


--
-- Name: BookmarkQuestion id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."BookmarkQuestion" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."BookmarkQuestion_id_seq"'::regclass);


--
-- Name: ChapterFlashCard id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterFlashCard" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChapterFlashCard_id_seq"'::regclass);


--
-- Name: ChapterGlossary id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterGlossary" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChapterGlossary_id_seq"'::regclass);


--
-- Name: ChapterMindmap id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterMindmap" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChapterMindmap_id_seq"'::regclass);


--
-- Name: ChapterNote id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterNote" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChapterNote_id_seq"'::regclass);


--
-- Name: ChapterQuestionCopy id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterQuestionCopy" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChapterQuestion_id_seq"'::regclass);


--
-- Name: ChapterTask id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTask" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChapterTask_id_seq"'::regclass);


--
-- Name: ChapterTest id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTest" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChapterTest_id_seq"'::regclass);


--
-- Name: ChapterVideo id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterVideo" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChapterVideo_id_seq"'::regclass);


--
-- Name: ChatAnswer id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChatAnswer" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ChatAnswer_id_seq"'::regclass);


--
-- Name: Comment id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Comment" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Comment_id_seq"'::regclass);


--
-- Name: ConfigValue id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ConfigValue" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ConfigValue_id_seq"'::regclass);


--
-- Name: Constant id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Constant" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Constant_id_seq"'::regclass);


--
-- Name: CopyAnswer id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CopyAnswer" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CopyAnswer_id_seq"'::regclass);


--
-- Name: CopyTestAttempt id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CopyTestAttempt" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CopyTestAttempt_id_seq"'::regclass);


--
-- Name: Course id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Course" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Course_id_seq"'::regclass);


--
-- Name: CourseDetail id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseDetail" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CourseDetail_id_seq"'::regclass);


--
-- Name: CourseInvitation id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseInvitation" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CourseInvitation_id_seq"'::regclass);


--
-- Name: CourseOffer id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseOffer" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CourseOffer_id_seq"'::regclass);


--
-- Name: CourseTest id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseTest" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CourseTest_id_seq"'::regclass);


--
-- Name: CourseTestimonial id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseTestimonial" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CourseTestimonial_id_seq"'::regclass);


--
-- Name: CustomerIssue id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CustomerIssue_id_seq"'::regclass);


--
-- Name: CustomerIssueType id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssueType" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CustomerIssueType_id_seq"'::regclass);


--
-- Name: CustomerSupport id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerSupport" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."CustomerSupport_id_seq"'::regclass);


--
-- Name: DailyUserEvent id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DailyUserEvent" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."DailyUserEvent_id_seq"'::regclass);


--
-- Name: Delivery id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Delivery" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Delivery_id_seq"'::regclass);


--
-- Name: Doubt id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Doubt" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Doubt_id_seq"'::regclass);


--
-- Name: DoubtAnswer id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DoubtAnswer" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."DoubtAnswer_id_seq"'::regclass);


--
-- Name: DuplicateChapter id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DuplicateChapter" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."DuplicateChapter_id_seq"'::regclass);


--
-- Name: DuplicatePost id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DuplicatePost" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."DuplicatePost_id_seq"'::regclass);


--
-- Name: DuplicateQuestion id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DuplicateQuestion" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."DuplicateQuestion_id_seq"'::regclass);


--
-- Name: FcmToken id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."FcmToken" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."FcmToken_id_seq"'::regclass);


--
-- Name: FestivalDiscount id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."FestivalDiscount" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."FestivalDiscount_id_seq"'::regclass);


--
-- Name: FlashCard id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."FlashCard" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."FlashCard_id_seq"'::regclass);


--
-- Name: Glossary id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Glossary" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Glossary_id_seq"'::regclass);


--
-- Name: Group id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Group" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Group_id_seq"'::regclass);


--
-- Name: Installment id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Installment" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Installment_id_seq"'::regclass);


--
-- Name: Message id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Message" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Message_id_seq"'::regclass);


--
-- Name: Motivation id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Motivation" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Motivation_id_seq"'::regclass);


--
-- Name: NCERTQuestion id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NCERTQuestion" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."NCERTQuestion_id_seq"'::regclass);


--
-- Name: NEETExamResult id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NEETExamResult" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."NEETExamResult_id_seq"'::regclass);


--
-- Name: NksAppVersion id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NksAppVersion" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."NksAppVersion_id_seq"'::regclass);


--
-- Name: NotDuplicateQuestion id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NotDuplicateQuestion" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."NotDuplicateQuestion_id_seq"'::regclass);


--
-- Name: Note id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Note" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Note_id_seq"'::regclass);


--
-- Name: Notification id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Notification" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Notification_id_seq"'::regclass);


--
-- Name: OldCourseTest id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."OldCourseTest" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."OldCourseTest_id_seq"'::regclass);


--
-- Name: Payment id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Payment" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Payment_id_seq"'::regclass);


--
-- Name: PaymentCourseInvitation id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."PaymentCourseInvitation" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."PaymentCourseInvitation_id_seq"'::regclass);


--
-- Name: Post id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Post" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Post_id_seq"'::regclass);


--
-- Name: Question id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Question" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Question_id_seq"'::regclass);


--
-- Name: QuestionDetail id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionDetail" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."QuestionDetail_id_seq"'::regclass);


--
-- Name: QuestionExplanation id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionExplanation" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."QuestionExplanation_id_seq"'::regclass);


--
-- Name: QuestionHint id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionHint" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."QuestionHint_id_seq"'::regclass);


--
-- Name: QuestionSubTopic id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionSubTopic" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."QuestionSubTopic_id_seq"'::regclass);


--
-- Name: QuestionTranslation id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionTranslation" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."QuestionTranslation_id_seq"'::regclass);


--
-- Name: Quiz id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Quiz" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Quiz_id_seq"'::regclass);


--
-- Name: SEOData id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SEOData" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."SEOData_id_seq"'::regclass);


--
-- Name: Schedule id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Schedule" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Schedule_id_seq"'::regclass);


--
-- Name: ScheduleItem id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItem" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ScheduleItem_id_seq"'::regclass);


--
-- Name: ScheduleItemAsset id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItemAsset" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ScheduleItemAsset_id_seq"'::regclass);


--
-- Name: ScheduleItemUser id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItemUser" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ScheduleItemUser_id_seq"'::regclass);


--
-- Name: ScheduledTask id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduledTask" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."ScheduledTask_id_seq"'::regclass);


--
-- Name: Section id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Section" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Section_id_seq"'::regclass);


--
-- Name: SectionContent id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SectionContent" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."SectionContent_id_seq"'::regclass);


--
-- Name: StudentNote id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."StudentNote" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."StudentNote_id_seq"'::regclass);


--
-- Name: StudentOnboardingEvents id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."StudentOnboardingEvents" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."StudentOnboardingEvents_id_seq"'::regclass);


--
-- Name: SubTopic id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SubTopic" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."SubTopic_id_seq"'::regclass);


--
-- Name: Subject id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Subject" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Subject_id_seq"'::regclass);


--
-- Name: SubjectChapter id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SubjectChapter" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."SubjectChapter_id_seq"'::regclass);


--
-- Name: Target id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Target" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Target_id_seq"'::regclass);


--
-- Name: TargetChapter id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TargetChapter" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."TargetChapter_id_seq"'::regclass);


--
-- Name: Task id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Task" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Task_id_seq"'::regclass);


--
-- Name: Test id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Test" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Test_id_seq"'::regclass);


--
-- Name: TestAttempt id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TestAttempt" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."TestAttempt_id_seq"'::regclass);


--
-- Name: TestAttemptPostmartem id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TestAttemptPostmartem" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."TestAttemptPostmartem_id_seq"'::regclass);


--
-- Name: TestQuestion id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TestQuestion" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."TestQuestion_id_seq"'::regclass);


--
-- Name: Topic id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Topic" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Topic_id_seq"'::regclass);


--
-- Name: TopicAssetOld id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TopicAssetOld" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."TopicAsset_id_seq"'::regclass);


--
-- Name: User id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."User" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."User_id_seq"'::regclass);


--
-- Name: UserChapterStat id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserChapterStat" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserChapterStat_id_seq"'::regclass);


--
-- Name: UserClaim id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserClaim" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserClaim_id_seq"'::regclass);


--
-- Name: UserCourse id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserCourse" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserCourse_id_seq"'::regclass);


--
-- Name: UserFlashCard id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserFlashCard" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserFlashCard_id_seq"'::regclass);


--
-- Name: UserHighlightedNote id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserHighlightedNote" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserHighlightedNote_id_seq"'::regclass);


--
-- Name: UserLogin id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserLogin" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserLogin_id_seq"'::regclass);


--
-- Name: UserNoteStat id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserNoteStat" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserNoteStat_id_seq"'::regclass);


--
-- Name: UserProfile id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserProfile" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserProfile_id_seq"'::regclass);


--
-- Name: UserResult id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserResult" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserResult_id_seq"'::regclass);


--
-- Name: UserScheduledTask id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserScheduledTask" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserScheduledTask_id_seq"'::regclass);


--
-- Name: UserSectionStat id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserSectionStat" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserSectionStat_id_seq"'::regclass);


--
-- Name: UserTask id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserTask" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserTask_id_seq"'::regclass);


--
-- Name: UserTodo id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserTodo" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserTodo_id_seq"'::regclass);


--
-- Name: UserVideoStat id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserVideoStat" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."UserVideoStat_id_seq"'::regclass);


--
-- Name: Video id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Video" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Video_id_seq"'::regclass);


--
-- Name: VideoAnnotation id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoAnnotation" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."VideoAnnotation_id_seq"'::regclass);


--
-- Name: VideoLink id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoLink" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."VideoLink_id_seq"'::regclass);


--
-- Name: VideoQuestion id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoQuestion" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."VideoQuestion_id_seq"'::regclass);


--
-- Name: VideoSubTopic id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoSubTopic" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."VideoSubTopic_id_seq"'::regclass);


--
-- Name: VideoTest id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoTest" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."VideoTest_id_seq"'::regclass);


--
-- Name: Vote id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Vote" ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test."Vote_id_seq"'::regclass);


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.active_admin_comments_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.active_storage_blobs_id_seq'::regclass);


--
-- Name: admin_users id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.admin_users ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.admin_users_id_seq'::regclass);


--
-- Name: doubt_admins id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_admins ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.doubt_admins_id_seq'::regclass);


--
-- Name: doubt_chat_channels id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_chat_channels ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.doubt_chat_channels_id_seq'::regclass);


--
-- Name: doubt_chat_doubt_answers id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_chat_doubt_answers ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.doubt_chat_doubt_answers_id_seq'::regclass);


--
-- Name: doubt_chat_doubts id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_chat_doubts ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.doubt_chat_doubts_id_seq'::regclass);


--
-- Name: student_coaches id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.student_coaches ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.student_coaches_id_seq'::regclass);


--
-- Name: user_actions id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.user_actions ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.user_actions_id_seq'::regclass);


--
-- Name: version_associations id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.version_associations ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.version_associations_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.versions ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.versions_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.votes ALTER COLUMN id SET DEFAULT nextval('RubyActiveAdmin_test.votes_id_seq'::regclass);


--
-- Name: Question Question_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Question"
    ADD CONSTRAINT "Question_pkey" PRIMARY KEY (id);


--
-- Name: QuestionAnalytics; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."QuestionAnalytics" AS
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
               FROM RubyActiveAdmin_test."TopicQuestion",
                RubyActiveAdmin_test."Topic",
                RubyActiveAdmin_test."Subject"
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
           FROM (RubyActiveAdmin_test."Question"
             JOIN RubyActiveAdmin_test."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question".type = ANY (ARRAY['MCQ-SO'::RubyActiveAdmin_test."enum_Question_type", 'MCQ-AR'::RubyActiveAdmin_test."enum_Question_type"])))))
          GROUP BY "Question".id) "TempData"
  WITH NO DATA;


--
-- Name: QuestionAnalytics11; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."QuestionAnalytics11" AS
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
               FROM RubyActiveAdmin_test."TopicQuestion",
                RubyActiveAdmin_test."Topic",
                RubyActiveAdmin_test."Subject"
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
           FROM (RubyActiveAdmin_test."Question"
             LEFT JOIN RubyActiveAdmin_test."Answer" ON ((("Question".id = "Answer"."questionId") AND ("Question".type = ANY (ARRAY['MCQ-SO'::RubyActiveAdmin_test."enum_Question_type", 'MCQ-AR'::RubyActiveAdmin_test."enum_Question_type"])))))
          GROUP BY "Question".id) "TempData"
  WITH NO DATA;


--
-- Name: QuestionAnalytics25; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."QuestionAnalytics25" AS
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
               FROM RubyActiveAdmin_test."TopicQuestion",
                RubyActiveAdmin_test."Topic",
                RubyActiveAdmin_test."Subject"
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
           FROM (RubyActiveAdmin_test."Question"
             LEFT JOIN RubyActiveAdmin_test."Answer" ON (("Question".id = "Answer"."questionId")))
          GROUP BY "Question".id) "TempData"
  WITH NO DATA;


--
-- Name: TestAttempt TestAttempt_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TestAttempt"
    ADD CONSTRAINT "TestAttempt_pkey" PRIMARY KEY (id);


--
-- Name: TestLeaderBoard; Type: MATERIALIZED VIEW; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE MATERIALIZED VIEW RubyActiveAdmin_test."TestLeaderBoard" AS
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
                   FROM RubyActiveAdmin_test."TestAttempt",
                    RubyActiveAdmin_test."Test"
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
-- Name: ActiveFlashCardChapter ActiveFlashCardChapter_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ActiveFlashCardChapter"
    ADD CONSTRAINT "ActiveFlashCardChapter_pkey" PRIMARY KEY (id);


--
-- Name: Advertisement Advertisement_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Advertisement"
    ADD CONSTRAINT "Advertisement_pkey" PRIMARY KEY (id);


--
-- Name: Announcement Announcement_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Announcement"
    ADD CONSTRAINT "Announcement_pkey" PRIMARY KEY (id);


--
-- Name: Answer Answer_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Answer"
    ADD CONSTRAINT "Answer_pkey" PRIMARY KEY (id);


--
-- Name: AppVersion AppVersion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."AppVersion"
    ADD CONSTRAINT "AppVersion_pkey" PRIMARY KEY (id);


--
-- Name: BookmarkQuestion BookmarkQuestion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."BookmarkQuestion"
    ADD CONSTRAINT "BookmarkQuestion_pkey" PRIMARY KEY (id);


--
-- Name: ChapterFlashCard ChapterFlashCard_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterFlashCard"
    ADD CONSTRAINT "ChapterFlashCard_pkey" PRIMARY KEY (id);


--
-- Name: ChapterGlossary ChapterGlossary_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterGlossary"
    ADD CONSTRAINT "ChapterGlossary_pkey" PRIMARY KEY (id);


--
-- Name: ChapterMindmap ChapterMindmap_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterMindmap"
    ADD CONSTRAINT "ChapterMindmap_pkey" PRIMARY KEY (id);


--
-- Name: ChapterNote ChapterNote_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterNote"
    ADD CONSTRAINT "ChapterNote_pkey" PRIMARY KEY (id);


--
-- Name: ChapterQuestion ChapterQuestion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterQuestion"
    ADD CONSTRAINT "ChapterQuestion_pkey" PRIMARY KEY (id);


--
-- Name: ChapterTask ChapterTask_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTask"
    ADD CONSTRAINT "ChapterTask_pkey" PRIMARY KEY (id);


--
-- Name: ChapterTest ChapterTest_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTest"
    ADD CONSTRAINT "ChapterTest_pkey" PRIMARY KEY (id);


--
-- Name: ChapterVideo ChapterVideo_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterVideo"
    ADD CONSTRAINT "ChapterVideo_pkey" PRIMARY KEY (id);


--
-- Name: ChatAnswer ChatAnswer_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChatAnswer"
    ADD CONSTRAINT "ChatAnswer_pkey" PRIMARY KEY (id);


--
-- Name: Comment Comment_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Comment"
    ADD CONSTRAINT "Comment_pkey" PRIMARY KEY (id);


--
-- Name: ConfigValue ConfigValue_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ConfigValue"
    ADD CONSTRAINT "ConfigValue_pkey" PRIMARY KEY (id);


--
-- Name: Constant Constant_key_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Constant"
    ADD CONSTRAINT "Constant_key_key" UNIQUE (key);


--
-- Name: Constant Constant_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Constant"
    ADD CONSTRAINT "Constant_pkey" PRIMARY KEY (id);


--
-- Name: CopyTestAttempt CopyTestAttempt_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CopyTestAttempt"
    ADD CONSTRAINT "CopyTestAttempt_pkey" PRIMARY KEY (id);


--
-- Name: CourseDetail CourseDetail_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseDetail"
    ADD CONSTRAINT "CourseDetail_pkey" PRIMARY KEY (id);


--
-- Name: CourseInvitation CourseInvitation_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseInvitation"
    ADD CONSTRAINT "CourseInvitation_pkey" PRIMARY KEY (id);


--
-- Name: CourseOffer CourseOffer_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseOffer"
    ADD CONSTRAINT "CourseOffer_pkey" PRIMARY KEY (id);


--
-- Name: CourseTest CourseTest_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseTest"
    ADD CONSTRAINT "CourseTest_pkey" PRIMARY KEY (id);


--
-- Name: CourseTestimonial CourseTestimonial_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseTestimonial"
    ADD CONSTRAINT "CourseTestimonial_pkey" PRIMARY KEY (id);


--
-- Name: Course Course_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Course"
    ADD CONSTRAINT "Course_pkey" PRIMARY KEY (id);


--
-- Name: CustomerIssueType CustomerIssueType_code_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssueType"
    ADD CONSTRAINT "CustomerIssueType_code_key" UNIQUE (code);


--
-- Name: CustomerIssueType CustomerIssueType_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssueType"
    ADD CONSTRAINT "CustomerIssueType_pkey" PRIMARY KEY (id);


--
-- Name: CustomerIssue CustomerIssue_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue"
    ADD CONSTRAINT "CustomerIssue_pkey" PRIMARY KEY (id);


--
-- Name: CustomerSupport CustomerSupport_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerSupport"
    ADD CONSTRAINT "CustomerSupport_pkey" PRIMARY KEY (id);


--
-- Name: DailyUserEvent DailyUserEvent_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DailyUserEvent"
    ADD CONSTRAINT "DailyUserEvent_pkey" PRIMARY KEY (id);


--
-- Name: DailyUserEvent DailyUserEvent_userId_eventDate_event_courseId_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DailyUserEvent"
    ADD CONSTRAINT "DailyUserEvent_userId_eventDate_event_courseId_key" UNIQUE ("userId", "eventDate", event, "courseId");


--
-- Name: Delivery Delivery_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Delivery"
    ADD CONSTRAINT "Delivery_pkey" PRIMARY KEY (id);


--
-- Name: DoubtAnswer DoubtAnswer_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DoubtAnswer"
    ADD CONSTRAINT "DoubtAnswer_pkey" PRIMARY KEY (id);


--
-- Name: Doubt Doubt_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Doubt"
    ADD CONSTRAINT "Doubt_pkey" PRIMARY KEY (id);


--
-- Name: DuplicateChapter DuplicateChapter_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DuplicateChapter"
    ADD CONSTRAINT "DuplicateChapter_pkey" PRIMARY KEY (id);


--
-- Name: DuplicatePost DuplicatePost_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DuplicatePost"
    ADD CONSTRAINT "DuplicatePost_pkey" PRIMARY KEY (id);


--
-- Name: DuplicateQuestion DuplicateQuestion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DuplicateQuestion"
    ADD CONSTRAINT "DuplicateQuestion_pkey" PRIMARY KEY (id);


--
-- Name: DuplicateQuestion DuplicateQuestion_questionId1_questionId2_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DuplicateQuestion"
    ADD CONSTRAINT "DuplicateQuestion_questionId1_questionId2_key" UNIQUE ("questionId1", "questionId2");


--
-- Name: FcmToken FcmToken_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."FcmToken"
    ADD CONSTRAINT "FcmToken_pkey" PRIMARY KEY (id);


--
-- Name: FestivalDiscount FestivalDiscount_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."FestivalDiscount"
    ADD CONSTRAINT "FestivalDiscount_pkey" PRIMARY KEY (id);


--
-- Name: FlashCard FlashCard_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."FlashCard"
    ADD CONSTRAINT "FlashCard_pkey" PRIMARY KEY (id);


--
-- Name: Glossary Glossary_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Glossary"
    ADD CONSTRAINT "Glossary_pkey" PRIMARY KEY (id);


--
-- Name: Group Group_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Group"
    ADD CONSTRAINT "Group_pkey" PRIMARY KEY (id);


--
-- Name: Installment Installment_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Installment"
    ADD CONSTRAINT "Installment_pkey" PRIMARY KEY (id);


--
-- Name: Message Message_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Message"
    ADD CONSTRAINT "Message_pkey" PRIMARY KEY (id);


--
-- Name: Motivation Motivation_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Motivation"
    ADD CONSTRAINT "Motivation_pkey" PRIMARY KEY (id);


--
-- Name: NCERTQuestion NCERTQuestion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NCERTQuestion"
    ADD CONSTRAINT "NCERTQuestion_pkey" PRIMARY KEY (id);


--
-- Name: NEETExamResult NEETExamResult_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NEETExamResult"
    ADD CONSTRAINT "NEETExamResult_pkey" PRIMARY KEY (id);


--
-- Name: NksAppVersion NksAppVersion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NksAppVersion"
    ADD CONSTRAINT "NksAppVersion_pkey" PRIMARY KEY (id);


--
-- Name: NotDuplicateQuestion NotDuplicateQuestion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NotDuplicateQuestion"
    ADD CONSTRAINT "NotDuplicateQuestion_pkey" PRIMARY KEY (id);


--
-- Name: NotDuplicateQuestion NotDuplicateQuestion_questionId1_questionId2_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NotDuplicateQuestion"
    ADD CONSTRAINT "NotDuplicateQuestion_questionId1_questionId2_key" UNIQUE ("questionId1", "questionId2");


--
-- Name: Note Note_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Note"
    ADD CONSTRAINT "Note_pkey" PRIMARY KEY (id);


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: OldCourseTest OldCourseTest_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."OldCourseTest"
    ADD CONSTRAINT "OldCourseTest_pkey" PRIMARY KEY (id);


--
-- Name: PaymentCourseInvitation PaymentCourseInvitation_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."PaymentCourseInvitation"
    ADD CONSTRAINT "PaymentCourseInvitation_pkey" PRIMARY KEY (id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: Post Post_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Post"
    ADD CONSTRAINT "Post_pkey" PRIMARY KEY (id);


--
-- Name: Post Post_url_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Post"
    ADD CONSTRAINT "Post_url_key" UNIQUE (url);


--
-- Name: QuestionCourse QuestionCourse_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionCourse"
    ADD CONSTRAINT "QuestionCourse_pkey" PRIMARY KEY ("questionId");


--
-- Name: QuestionDetail QuestionDetail_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionDetail"
    ADD CONSTRAINT "QuestionDetail_pkey" PRIMARY KEY (id);


--
-- Name: QuestionExplanation QuestionExplanation_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionExplanation"
    ADD CONSTRAINT "QuestionExplanation_pkey" PRIMARY KEY (id);


--
-- Name: QuestionHint QuestionHint_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionHint"
    ADD CONSTRAINT "QuestionHint_pkey" PRIMARY KEY (id);


--
-- Name: QuestionSubTopic QuestionSubTopic_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionSubTopic"
    ADD CONSTRAINT "QuestionSubTopic_pkey" PRIMARY KEY (id);


--
-- Name: QuestionTranslation QuestionTranslation_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionTranslation"
    ADD CONSTRAINT "QuestionTranslation_pkey" PRIMARY KEY (id);


--
-- Name: QuestionTranslation QuestionTranslation_questionId_language_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionTranslation"
    ADD CONSTRAINT "QuestionTranslation_questionId_language_key" UNIQUE ("questionId", language);


--
-- Name: Quiz Quiz_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Quiz"
    ADD CONSTRAINT "Quiz_pkey" PRIMARY KEY (id);


--
-- Name: SEOData SEOData_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SEOData"
    ADD CONSTRAINT "SEOData_pkey" PRIMARY KEY (id);


--
-- Name: ScheduleItemAsset ScheduleItemAsset_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItemAsset"
    ADD CONSTRAINT "ScheduleItemAsset_pkey" PRIMARY KEY (id);


--
-- Name: ScheduleItemUser ScheduleItemUser_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItemUser"
    ADD CONSTRAINT "ScheduleItemUser_pkey" PRIMARY KEY (id);


--
-- Name: ScheduleItem ScheduleItem_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItem"
    ADD CONSTRAINT "ScheduleItem_pkey" PRIMARY KEY (id);


--
-- Name: Schedule Schedule_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Schedule"
    ADD CONSTRAINT "Schedule_pkey" PRIMARY KEY (id);


--
-- Name: ScheduledTask ScheduledTask_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduledTask"
    ADD CONSTRAINT "ScheduledTask_pkey" PRIMARY KEY (id);


--
-- Name: SectionContent SectionContent_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SectionContent"
    ADD CONSTRAINT "SectionContent_pkey" PRIMARY KEY (id);


--
-- Name: Section Section_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Section"
    ADD CONSTRAINT "Section_pkey" PRIMARY KEY (id);


--
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- Name: StudentNote StudentNoteNCERTHighlightNoOverlap; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--
CREATE EXTENSION btree_gist WITH SCHEMA RubyActiveAdmin_test;

ALTER TABLE ONLY RubyActiveAdmin_test."StudentNote"
    ADD CONSTRAINT "StudentNoteNCERTHighlightNoOverlap" EXCLUDE USING gist ("userId" WITH =, "noteId" WITH =, "noteRange" WITH &&);


--
-- Name: StudentNote StudentNote_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."StudentNote"
    ADD CONSTRAINT "StudentNote_pkey" PRIMARY KEY (id);


--
-- Name: StudentOnboardingEvents StudentOnboardingEvents_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."StudentOnboardingEvents"
    ADD CONSTRAINT "StudentOnboardingEvents_pkey" PRIMARY KEY (id);


--
-- Name: SubTopic SubTopic_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SubTopic"
    ADD CONSTRAINT "SubTopic_pkey" PRIMARY KEY (id);


--
-- Name: SubjectChapter SubjectChapter_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SubjectChapter"
    ADD CONSTRAINT "SubjectChapter_pkey" PRIMARY KEY (id);


--
-- Name: Subject Subject_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Subject"
    ADD CONSTRAINT "Subject_pkey" PRIMARY KEY (id);


--
-- Name: TargetChapter TargetChapter_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TargetChapter"
    ADD CONSTRAINT "TargetChapter_pkey" PRIMARY KEY (id);


--
-- Name: Target Target_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Target"
    ADD CONSTRAINT "Target_pkey" PRIMARY KEY (id);


--
-- Name: Task Task_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Task"
    ADD CONSTRAINT "Task_pkey" PRIMARY KEY (id);


--
-- Name: TestAttemptPostmartem TestAttemptPostmartem_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TestAttemptPostmartem"
    ADD CONSTRAINT "TestAttemptPostmartem_pkey" PRIMARY KEY (id);


--
-- Name: TestQuestion TestQuestion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TestQuestion"
    ADD CONSTRAINT "TestQuestion_pkey" PRIMARY KEY (id);


--
-- Name: Test Test_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Test"
    ADD CONSTRAINT "Test_pkey" PRIMARY KEY (id);


--
-- Name: TopicAssetOld TopicAsset_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TopicAssetOld"
    ADD CONSTRAINT "TopicAsset_pkey" PRIMARY KEY (id);


--
-- Name: Topic Topic_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Topic"
    ADD CONSTRAINT "Topic_pkey" PRIMARY KEY (id);


--
-- Name: UserChapterStat UserChapterStat_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserChapterStat"
    ADD CONSTRAINT "UserChapterStat_pkey" PRIMARY KEY (id);


--
-- Name: UserClaim UserClaim_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserClaim"
    ADD CONSTRAINT "UserClaim_pkey" PRIMARY KEY (id);


--
-- Name: UserCourse UserCourse_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserCourse"
    ADD CONSTRAINT "UserCourse_pkey" PRIMARY KEY (id);


--
-- Name: UserFlashCard UserFlashCard_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserFlashCard"
    ADD CONSTRAINT "UserFlashCard_pkey" PRIMARY KEY (id);


--
-- Name: UserHighlightedNote UserHighlightedNote_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserHighlightedNote"
    ADD CONSTRAINT "UserHighlightedNote_pkey" PRIMARY KEY (id);


--
-- Name: UserLogin UserLogin_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserLogin"
    ADD CONSTRAINT "UserLogin_pkey" PRIMARY KEY (id);


--
-- Name: UserNoteStat UserNoteStat_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserNoteStat"
    ADD CONSTRAINT "UserNoteStat_pkey" PRIMARY KEY (id);


--
-- Name: UserProfile UserProfile_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserProfile"
    ADD CONSTRAINT "UserProfile_pkey" PRIMARY KEY (id);


--
-- Name: UserResult UserResult_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserResult"
    ADD CONSTRAINT "UserResult_pkey" PRIMARY KEY (id);


--
-- Name: UserScheduledTask UserScheduledTask_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserScheduledTask"
    ADD CONSTRAINT "UserScheduledTask_pkey" PRIMARY KEY (id);


--
-- Name: UserSectionStat UserSectionStat_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserSectionStat"
    ADD CONSTRAINT "UserSectionStat_pkey" PRIMARY KEY (id);


--
-- Name: UserTask UserTask_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserTask"
    ADD CONSTRAINT "UserTask_pkey" PRIMARY KEY (id);


--
-- Name: UserTodo UserTodo_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserTodo"
    ADD CONSTRAINT "UserTodo_pkey" PRIMARY KEY (id);


--
-- Name: UserVideoStat UserVideoStat_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserVideoStat"
    ADD CONSTRAINT "UserVideoStat_pkey" PRIMARY KEY (id);


--
-- Name: User User_email_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."User"
    ADD CONSTRAINT "User_email_key" UNIQUE (email);


--
-- Name: User User_phone_key; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."User"
    ADD CONSTRAINT "User_phone_key" UNIQUE (phone);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: VideoAnnotation VideoAnnotation_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoAnnotation"
    ADD CONSTRAINT "VideoAnnotation_pkey" PRIMARY KEY (id);


--
-- Name: VideoLink VideoLink_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoLink"
    ADD CONSTRAINT "VideoLink_pkey" PRIMARY KEY (id);


--
-- Name: VideoQuestion VideoQuestion_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoQuestion"
    ADD CONSTRAINT "VideoQuestion_pkey" PRIMARY KEY (id);


--
-- Name: VideoSubTopic VideoSubTopic_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoSubTopic"
    ADD CONSTRAINT "VideoSubTopic_pkey" PRIMARY KEY (id);


--
-- Name: VideoTest VideoTest_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoTest"
    ADD CONSTRAINT "VideoTest_pkey" PRIMARY KEY (id);


--
-- Name: Video Video_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Video"
    ADD CONSTRAINT "Video_pkey" PRIMARY KEY (id);


--
-- Name: Vote Vote_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Vote"
    ADD CONSTRAINT "Vote_pkey" PRIMARY KEY (id);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: BookmarkQuestion bookmarkquestion_user_id_question_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."BookmarkQuestion"
    ADD CONSTRAINT bookmarkquestion_user_id_question_id UNIQUE ("userId", "questionId");


--
-- Name: ChapterNote chapternote_chapter_id_note_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterNote"
    ADD CONSTRAINT chapternote_chapter_id_note_id UNIQUE ("chapterId", "noteId");


--
-- Name: ChapterQuestion chapterquestion1_chapter_id_question_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterQuestion"
    ADD CONSTRAINT chapterquestion1_chapter_id_question_id UNIQUE ("chapterId", "questionId");


--
-- Name: ChapterQuestionCopy chapterquestion_chapter_id_question_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterQuestionCopy"
    ADD CONSTRAINT chapterquestion_chapter_id_question_id UNIQUE ("chapterId", "questionId");


--
-- Name: ChapterTest chaptertest_chapter_id_test_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTest"
    ADD CONSTRAINT chaptertest_chapter_id_test_id UNIQUE ("chapterId", "testId");


--
-- Name: ChapterVideo chaptervideo_chapter_id_video_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterVideo"
    ADD CONSTRAINT chaptervideo_chapter_id_video_id UNIQUE ("chapterId", "videoId");


--
-- Name: doubt_admins doubt_admins_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_admins
    ADD CONSTRAINT doubt_admins_pkey PRIMARY KEY (id);


--
-- Name: doubt_chat_channels doubt_chat_channels_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_chat_channels
    ADD CONSTRAINT doubt_chat_channels_pkey PRIMARY KEY (id);


--
-- Name: doubt_chat_doubt_answers doubt_chat_doubt_answers_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_chat_doubt_answers
    ADD CONSTRAINT doubt_chat_doubt_answers_pkey PRIMARY KEY (id);


--
-- Name: doubt_chat_doubts doubt_chat_doubts_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_chat_doubts
    ADD CONSTRAINT doubt_chat_doubts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: CourseOffer single_applicable_course_offer; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseOffer"
    ADD CONSTRAINT single_applicable_course_offer UNIQUE ("courseId", email, "offerExpiryAt", title);


--
-- Name: student_coaches student_coaches_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.student_coaches
    ADD CONSTRAINT student_coaches_pkey PRIMARY KEY (id);


--
-- Name: SubjectChapter subject_chapter_subject_id_chapter_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SubjectChapter"
    ADD CONSTRAINT subject_chapter_subject_id_chapter_id UNIQUE ("chapterId", "subjectId");


--
-- Name: ScheduleItemUser u_schedule_item_user_user; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItemUser"
    ADD CONSTRAINT u_schedule_item_user_user UNIQUE ("scheduleItemId", "userId");


--
-- Name: UserLogin u_user_id_platform; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserLogin"
    ADD CONSTRAINT u_user_id_platform UNIQUE ("userId", platform);


--
-- Name: DuplicateChapter unique_origId_dupId; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DuplicateChapter"
    ADD CONSTRAINT "unique_origId_dupId" UNIQUE ("origId", "dupId");


--
-- Name: NCERTQuestion unique_questionId; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NCERTQuestion"
    ADD CONSTRAINT "unique_questionId" UNIQUE ("questionId");


--
-- Name: SectionContent unique_section_content_entry; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SectionContent"
    ADD CONSTRAINT unique_section_content_entry UNIQUE ("sectionId", "contentId", "contentType");


--
-- Name: Vote unique_vote; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Vote"
    ADD CONSTRAINT unique_vote UNIQUE ("userId", "ownerId", "ownerType");


--
-- Name: user_actions user_actions_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.user_actions
    ADD CONSTRAINT user_actions_pkey PRIMARY KEY (id);


--
-- Name: UserChapterStat userchapterstat_user_id_chapter_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserChapterStat"
    ADD CONSTRAINT userchapterstat_user_id_chapter_id UNIQUE ("userId", "chapterId");


--
-- Name: UserNoteStat usernotestat_user_id_note_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserNoteStat"
    ADD CONSTRAINT usernotestat_user_id_note_id UNIQUE ("userId", "noteId");


--
-- Name: UserSectionStat usersectionstat_user_id_section_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserSectionStat"
    ADD CONSTRAINT usersectionstat_user_id_section_id UNIQUE ("userId", "sectionId");


--
-- Name: UserVideoStat uservideostat_user_id_video_id; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserVideoStat"
    ADD CONSTRAINT uservideostat_user_id_video_id UNIQUE ("userId", "videoId");


--
-- Name: version_associations version_associations_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.version_associations
    ADD CONSTRAINT version_associations_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: Advertisement_expiryAt_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Advertisement_expiryAt_idx" ON RubyActiveAdmin_test."Advertisement" USING btree ("expiryAt");


--
-- Name: Advertisement_platform_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Advertisement_platform_idx" ON RubyActiveAdmin_test."Advertisement" USING btree (platform);


--
-- Name: ChapterFlashCard_chapterId_flashCardId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "ChapterFlashCard_chapterId_flashCardId_idx" ON RubyActiveAdmin_test."ChapterFlashCard" USING btree ("chapterId", "flashCardId");


--
-- Name: ChapterFlashCard_chapterId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "ChapterFlashCard_chapterId_idx" ON RubyActiveAdmin_test."ChapterFlashCard" USING btree ("chapterId");


--
-- Name: ChapterFlashCard_flashCardId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "ChapterFlashCard_flashCardId_idx" ON RubyActiveAdmin_test."ChapterFlashCard" USING btree ("flashCardId");


--
-- Name: CourseOffer_email_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "CourseOffer_email_idx" ON RubyActiveAdmin_test."CourseOffer" USING btree (email);


--
-- Name: CourseOffer_email_phone_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "CourseOffer_email_phone_idx" ON RubyActiveAdmin_test."CourseOffer" USING btree (email, phone);


--
-- Name: CourseOffer_hidden_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "CourseOffer_hidden_idx" ON RubyActiveAdmin_test."CourseOffer" USING btree (hidden);


--
-- Name: CourseOffer_offerExpiryAt_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "CourseOffer_offerExpiryAt_idx" ON RubyActiveAdmin_test."CourseOffer" USING btree ("offerExpiryAt");


--
-- Name: CourseOffer_phone_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "CourseOffer_phone_idx" ON RubyActiveAdmin_test."CourseOffer" USING btree (phone);


--
-- Name: CourseTest_courseId_testId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "CourseTest_courseId_testId_idx" ON RubyActiveAdmin_test."CourseTest" USING btree ("courseId", "testId");


--
-- Name: CourseTestimonial_courseId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "CourseTestimonial_courseId_idx" ON RubyActiveAdmin_test."CourseTestimonial" USING btree ("courseId");


--
-- Name: Course_package; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Course_package" ON RubyActiveAdmin_test."Course" USING btree (package);


--
-- Name: CustomerIssue_questionId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "CustomerIssue_questionId_idx" ON RubyActiveAdmin_test."CustomerIssue" USING btree ("questionId");


--
-- Name: CustomerIssue_videoId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "CustomerIssue_videoId_idx" ON RubyActiveAdmin_test."CustomerIssue" USING btree ("videoId");


--
-- Name: DailyUserEvent_courseId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "DailyUserEvent_courseId_idx" ON RubyActiveAdmin_test."DailyUserEvent" USING btree ("courseId");


--
-- Name: DailyUserEvent_eventCount_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "DailyUserEvent_eventCount_idx" ON RubyActiveAdmin_test."DailyUserEvent" USING btree ("eventCount");


--
-- Name: Doubt_answer_doubt_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Doubt_answer_doubt_id" ON RubyActiveAdmin_test."DoubtAnswer" USING btree ("doubtId");


--
-- Name: Doubt_answer_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Doubt_answer_user_id" ON RubyActiveAdmin_test."DoubtAnswer" USING btree ("userId");


--
-- Name: Doubt_created_at_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Doubt_created_at_idx" ON RubyActiveAdmin_test."Doubt" USING btree ("createdAt");


--
-- Name: Doubt_question_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Doubt_question_id" ON RubyActiveAdmin_test."Doubt" USING btree ("questionId");


--
-- Name: Doubt_topic_id_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Doubt_topic_id_idx" ON RubyActiveAdmin_test."Doubt" USING btree ("topicId");


--
-- Name: Doubt_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Doubt_user_id" ON RubyActiveAdmin_test."Doubt" USING btree ("userId");


--
-- Name: DuplicateChapter_dupId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "DuplicateChapter_dupId_idx" ON RubyActiveAdmin_test."DuplicateChapter" USING btree ("dupId");


--
-- Name: DuplicateChapter_dupId_idx1; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "DuplicateChapter_dupId_idx1" ON RubyActiveAdmin_test."DuplicateChapter" USING btree ("dupId");


--
-- Name: DuplicateChapter_origId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "DuplicateChapter_origId_idx" ON RubyActiveAdmin_test."DuplicateChapter" USING btree ("origId");


--
-- Name: FcmToken_platform_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "FcmToken_platform_idx" ON RubyActiveAdmin_test."FcmToken" USING btree (platform);


--
-- Name: FcmToken_userId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "FcmToken_userId_idx" ON RubyActiveAdmin_test."FcmToken" USING btree ("userId");


--
-- Name: NCERTQuestion_questionId_idx1; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "NCERTQuestion_questionId_idx1" ON RubyActiveAdmin_test."NCERTQuestion" USING btree ("questionId");


--
-- Name: Payment_amount_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Payment_amount_idx" ON RubyActiveAdmin_test."Payment" USING btree (amount);


--
-- Name: Payment_paymentDesc_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Payment_paymentDesc_idx" ON RubyActiveAdmin_test."Payment" USING btree ("paymentDesc");


--
-- Name: Payment_paymentMode_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Payment_paymentMode_idx" ON RubyActiveAdmin_test."Payment" USING btree ("paymentMode");


--
-- Name: Payment_status_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Payment_status_idx" ON RubyActiveAdmin_test."Payment" USING btree (status);


--
-- Name: Payment_userId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Payment_userId_idx" ON RubyActiveAdmin_test."Payment" USING btree ("userId");


--
-- Name: QuestionAnalytics11_correctPercentage_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics11_correctPercentage_idx" ON RubyActiveAdmin_test."QuestionAnalytics11" USING btree ("correctPercentage");


--
-- Name: QuestionAnalytics11_difficultyLevel_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics11_difficultyLevel_idx" ON RubyActiveAdmin_test."QuestionAnalytics11" USING btree ("difficultyLevel");


--
-- Name: QuestionAnalytics11_id_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "QuestionAnalytics11_id_idx" ON RubyActiveAdmin_test."QuestionAnalytics11" USING btree (id);


--
-- Name: QuestionAnalytics11_inFullCourse_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics11_inFullCourse_idx" ON RubyActiveAdmin_test."QuestionAnalytics11" USING btree ("inFullCourse");


--
-- Name: QuestionAnalytics11_incorrectReason1Count_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics11_incorrectReason1Count_idx" ON RubyActiveAdmin_test."QuestionAnalytics11" USING btree ("incorrectReason1Count");


--
-- Name: QuestionAnalytics11_incorrectReason2Count_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics11_incorrectReason2Count_idx" ON RubyActiveAdmin_test."QuestionAnalytics11" USING btree ("incorrectReason2Count");


--
-- Name: QuestionAnalytics11_incorrectReason3Count_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics11_incorrectReason3Count_idx" ON RubyActiveAdmin_test."QuestionAnalytics11" USING btree ("incorrectReason3Count");


--
-- Name: QuestionAnalytics11_tagExist_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics11_tagExist_idx" ON RubyActiveAdmin_test."QuestionAnalytics11" USING btree ("tagExist");


--
-- Name: QuestionAnalytics12_correctPercentage_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics12_correctPercentage_idx" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree ("correctPercentage");


--
-- Name: QuestionAnalytics12_difficultyLevel_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics12_difficultyLevel_idx" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree ("difficultyLevel");


--
-- Name: QuestionAnalytics12_id_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics12_id_idx" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree (id);


--
-- Name: QuestionAnalytics12_id_idx1; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "QuestionAnalytics12_id_idx1" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree (id);


--
-- Name: QuestionAnalytics12_inFullCourse_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics12_inFullCourse_idx" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree ("inFullCourse");


--
-- Name: QuestionAnalytics12_incorrectReason1Count_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics12_incorrectReason1Count_idx" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree ("incorrectReason1Count");


--
-- Name: QuestionAnalytics12_incorrectReason2Count_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics12_incorrectReason2Count_idx" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree ("incorrectReason2Count");


--
-- Name: QuestionAnalytics12_incorrectReason3Count_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics12_incorrectReason3Count_idx" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree ("incorrectReason3Count");


--
-- Name: QuestionAnalytics12_tagExist_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionAnalytics12_tagExist_idx" ON RubyActiveAdmin_test."QuestionAnalytics" USING btree ("tagExist");


--
-- Name: QuestionAnalytics_id25; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "QuestionAnalytics_id25" ON RubyActiveAdmin_test."QuestionAnalytics25" USING btree (id);


--
-- Name: QuestionCourse_questionId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionCourse_questionId_idx" ON RubyActiveAdmin_test."QuestionCourse" USING btree ("questionId");


--
-- Name: QuestionDetail_questionId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionDetail_questionId" ON RubyActiveAdmin_test."QuestionDetail" USING btree ("questionId");


--
-- Name: QuestionExplanation_courseId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionExplanation_courseId_idx" ON RubyActiveAdmin_test."QuestionExplanation" USING btree ("courseId");


--
-- Name: QuestionExplanation_questionId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionExplanation_questionId_idx" ON RubyActiveAdmin_test."QuestionExplanation" USING btree ("questionId");


--
-- Name: QuestionHint_courseId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionHint_courseId_idx" ON RubyActiveAdmin_test."QuestionHint" USING btree ("courseId");


--
-- Name: QuestionHint_questionId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "QuestionHint_questionId_idx" ON RubyActiveAdmin_test."QuestionHint" USING btree ("questionId");


--
-- Name: QuestionTranslation_questionId_language_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "QuestionTranslation_questionId_language_idx" ON RubyActiveAdmin_test."QuestionTranslation" USING btree ("questionId", language);


--
-- Name: Question_ncert_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Question_ncert_idx" ON RubyActiveAdmin_test."Question" USING btree (ncert);


--
-- Name: Question_paidAccess_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Question_paidAccess_idx" ON RubyActiveAdmin_test."Question" USING btree ("paidAccess");


--
-- Name: Question_topicId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Question_topicId_idx" ON RubyActiveAdmin_test."Question" USING btree ("topicId");


--
-- Name: Question_type_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Question_type_idx" ON RubyActiveAdmin_test."Question" USING btree (type);


--
-- Name: ScheduleItem_scheduleId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "ScheduleItem_scheduleId_idx" ON RubyActiveAdmin_test."ScheduleItem" USING btree ("scheduleId");


--
-- Name: ScheduleItem_scheduledAt_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "ScheduleItem_scheduledAt_idx" ON RubyActiveAdmin_test."ScheduleItem" USING btree ("scheduledAt");


--
-- Name: SelfCourseInvitationAccess; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "SelfCourseInvitationAccess" ON RubyActiveAdmin_test."CourseInvitation" USING btree (email, "courseId") WHERE ((admin_user_id IS NULL) AND ("createdAt" > '2020-09-09 00:00:00+00'::timestamp with time zone));


--
-- Name: StudentNote_flashcardId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "StudentNote_flashcardId_idx" ON RubyActiveAdmin_test."StudentNote" USING btree ("flashcardId");


--
-- Name: StudentNote_noteId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "StudentNote_noteId_idx" ON RubyActiveAdmin_test."StudentNote" USING btree ("noteId");


--
-- Name: StudentNote_questionId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "StudentNote_questionId_idx" ON RubyActiveAdmin_test."StudentNote" USING btree ("questionId");


--
-- Name: StudentNote_userId_flashcardId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "StudentNote_userId_flashcardId_idx" ON RubyActiveAdmin_test."StudentNote" USING btree ("userId", "flashcardId");


--
-- Name: StudentNote_userId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "StudentNote_userId_idx" ON RubyActiveAdmin_test."StudentNote" USING btree ("userId");


--
-- Name: StudentNote_userId_noteId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "StudentNote_userId_noteId_idx" ON RubyActiveAdmin_test."StudentNote" USING btree ("userId", "noteId");


--
-- Name: StudentNote_userId_questionId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "StudentNote_userId_questionId_idx" ON RubyActiveAdmin_test."StudentNote" USING btree ("userId", "questionId");


--
-- Name: SubTopic_topicId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "SubTopic_topicId" ON RubyActiveAdmin_test."SubTopic" USING btree ("topicId");


--
-- Name: SubjectChapter_chapterId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "SubjectChapter_chapterId_idx" ON RubyActiveAdmin_test."SubjectChapter" USING btree ("chapterId");


--
-- Name: SubjectChapter_deleted_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "SubjectChapter_deleted_idx" ON RubyActiveAdmin_test."SubjectChapter" USING btree (deleted);


--
-- Name: SubjectChapter_subjectId_chapterId_deleted_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "SubjectChapter_subjectId_chapterId_deleted_idx" ON RubyActiveAdmin_test."SubjectChapter" USING btree ("subjectId", "chapterId", deleted);


--
-- Name: SubjectChapter_subjectId_chapterId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "SubjectChapter_subjectId_chapterId_idx" ON RubyActiveAdmin_test."SubjectChapter" USING btree ("subjectId", "chapterId");


--
-- Name: SubjectChapter_subjectId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "SubjectChapter_subjectId_idx" ON RubyActiveAdmin_test."SubjectChapter" USING btree ("subjectId");


--
-- Name: Subject_courseId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Subject_courseId" ON RubyActiveAdmin_test."Subject" USING btree ("courseId");


--
-- Name: TargetChapter_chapterId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "TargetChapter_chapterId_idx" ON RubyActiveAdmin_test."TargetChapter" USING btree ("chapterId");


--
-- Name: TargetChapter_targetId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "TargetChapter_targetId_idx" ON RubyActiveAdmin_test."TargetChapter" USING btree ("targetId");


--
-- Name: Target_status_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Target_status_idx" ON RubyActiveAdmin_test."Target" USING btree (status);


--
-- Name: Target_testId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Target_testId_idx" ON RubyActiveAdmin_test."Target" USING btree ("testId");


--
-- Name: Target_updatedAt_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Target_updatedAt_idx" ON RubyActiveAdmin_test."Target" USING btree ("updatedAt");


--
-- Name: Target_userId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Target_userId_idx" ON RubyActiveAdmin_test."Target" USING btree ("userId");


--
-- Name: Target_userId_status_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Target_userId_status_idx" ON RubyActiveAdmin_test."Target" USING btree ("userId", status);


--
-- Name: Topic_free_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Topic_free_idx" ON RubyActiveAdmin_test."Topic" USING btree (free);


--
-- Name: Topic_subjectId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "Topic_subjectId" ON RubyActiveAdmin_test."Topic" USING btree ("subjectId");


--
-- Name: UserCourse_courseId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "UserCourse_courseId" ON RubyActiveAdmin_test."UserCourse" USING btree ("courseId");


--
-- Name: UserCourse_expiryAt_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "UserCourse_expiryAt_idx" ON RubyActiveAdmin_test."UserCourse" USING btree ("expiryAt");


--
-- Name: UserCourse_startedAt_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "UserCourse_startedAt_idx" ON RubyActiveAdmin_test."UserCourse" USING btree ("startedAt");


--
-- Name: UserCourse_userId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "UserCourse_userId" ON RubyActiveAdmin_test."UserCourse" USING btree ("userId");


--
-- Name: UserFlashCard_flashCardId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "UserFlashCard_flashCardId_idx" ON RubyActiveAdmin_test."UserFlashCard" USING btree ("flashCardId");


--
-- Name: UserFlashCard_userId_flashCardId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "UserFlashCard_userId_flashCardId_idx" ON RubyActiveAdmin_test."UserFlashCard" USING btree ("userId", "flashCardId");


--
-- Name: UserFlashCard_userId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "UserFlashCard_userId_idx" ON RubyActiveAdmin_test."UserFlashCard" USING btree ("userId");


--
-- Name: announcement_course_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX announcement_course_id ON RubyActiveAdmin_test."Announcement" USING btree ("courseId");


--
-- Name: announcement_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX announcement_user_id ON RubyActiveAdmin_test."Announcement" USING btree ("userId");


--
-- Name: answer_incorrect_answer_reason; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX answer_incorrect_answer_reason ON RubyActiveAdmin_test."Answer" USING btree ("incorrectAnswerReason");


--
-- Name: answer_test_attempt_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX answer_test_attempt_id ON RubyActiveAdmin_test."Answer" USING btree ("testAttemptId");


--
-- Name: answer_user_id_question_id_test_attempt_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX answer_user_id_question_id_test_attempt_id ON RubyActiveAdmin_test."Answer" USING btree ("userId", "questionId", "testAttemptId");


--
-- Name: bookmark_question_question_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX bookmark_question_question_id ON RubyActiveAdmin_test."BookmarkQuestion" USING btree ("questionId");


--
-- Name: bookmark_question_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX bookmark_question_user_id ON RubyActiveAdmin_test."BookmarkQuestion" USING btree ("userId");


--
-- Name: chapter_note_chapter_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_note_chapter_id ON RubyActiveAdmin_test."ChapterNote" USING btree ("chapterId");


--
-- Name: chapter_note_note_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_note_note_id ON RubyActiveAdmin_test."ChapterNote" USING btree ("noteId");


--
-- Name: chapter_question_chapter_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_question_chapter_id ON RubyActiveAdmin_test."ChapterQuestion" USING btree ("chapterId");


--
-- Name: chapter_question_question_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_question_question_id ON RubyActiveAdmin_test."ChapterQuestion" USING btree ("questionId");


--
-- Name: chapter_task_chapter_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_task_chapter_id ON RubyActiveAdmin_test."ChapterTask" USING btree ("chapterId");


--
-- Name: chapter_task_task_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_task_task_id ON RubyActiveAdmin_test."ChapterTask" USING btree ("taskId");


--
-- Name: chapter_test_chapter_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_test_chapter_id ON RubyActiveAdmin_test."ChapterTest" USING btree ("chapterId");


--
-- Name: chapter_test_test_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_test_test_id ON RubyActiveAdmin_test."ChapterTest" USING btree ("testId");


--
-- Name: chapter_video_chapter_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_video_chapter_id ON RubyActiveAdmin_test."ChapterVideo" USING btree ("chapterId");


--
-- Name: chapter_video_stat_chapter_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_video_stat_chapter_id ON RubyActiveAdmin_test."ChapterVideoStat" USING btree ("chapterId");


--
-- Name: chapter_video_video_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX chapter_video_video_id ON RubyActiveAdmin_test."ChapterVideo" USING btree ("videoId");


--
-- Name: common_topic_leader_board_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX common_topic_leader_board_user_id ON RubyActiveAdmin_test."CommonLeaderBoard" USING btree ("userId");


--
-- Name: correctPercentage10; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "correctPercentage10" ON RubyActiveAdmin_test."QuestionAnalytics25" USING btree ("correctPercentage");


--
-- Name: course_invitation_course_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX course_invitation_course_id ON RubyActiveAdmin_test."CourseInvitation" USING btree ("courseId");


--
-- Name: course_invitation_email; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX course_invitation_email ON RubyActiveAdmin_test."CourseInvitation" USING btree (email);


--
-- Name: course_invitation_phone; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX course_invitation_phone ON RubyActiveAdmin_test."CourseInvitation" USING btree (phone);


--
-- Name: course_offer_course_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX course_offer_course_id ON RubyActiveAdmin_test."CourseOffer" USING btree ("courseId");


--
-- Name: course_test_course_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX course_test_course_id ON RubyActiveAdmin_test."CourseTest" USING btree ("courseId");


--
-- Name: course_test_test_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX course_test_test_id ON RubyActiveAdmin_test."CourseTest" USING btree ("testId");


--
-- Name: customerissueunresolvedflashcard; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX customerissueunresolvedflashcard ON RubyActiveAdmin_test."CustomerIssue" USING btree ("userId", "flashCardId") WHERE (resolved = false);


--
-- Name: difficultyLevel10; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "difficultyLevel10" ON RubyActiveAdmin_test."QuestionAnalytics25" USING btree ("difficultyLevel");


--
-- Name: doubt_admins_doubtId_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "doubt_admins_doubtId_idx" ON RubyActiveAdmin_test.doubt_admins USING btree ("doubtId");


--
-- Name: inFullCourse10; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "inFullCourse10" ON RubyActiveAdmin_test."QuestionAnalytics25" USING btree ("inFullCourse");


--
-- Name: incorrectReason1Count10; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "incorrectReason1Count10" ON RubyActiveAdmin_test."QuestionAnalytics25" USING btree ("incorrectReason1Count");


--
-- Name: incorrectReason2Count10; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "incorrectReason2Count10" ON RubyActiveAdmin_test."QuestionAnalytics25" USING btree ("incorrectReason2Count");


--
-- Name: incorrectReason3Count10; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "incorrectReason3Count10" ON RubyActiveAdmin_test."QuestionAnalytics25" USING btree ("incorrectReason3Count");


--
-- Name: index_Glossary_on_word; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "index_Glossary_on_word" ON RubyActiveAdmin_test."Glossary" USING btree (word);


--
-- Name: index_ScheduleItemAsset_on_ScheduleItem_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "index_ScheduleItemAsset_on_ScheduleItem_id" ON RubyActiveAdmin_test."ScheduleItemAsset" USING btree ("ScheduleItem_id");


--
-- Name: index_TestQuestion_on_testId_and_questionId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "index_TestQuestion_on_testId_and_questionId" ON RubyActiveAdmin_test."TestQuestion" USING btree ("testId", "questionId");


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON RubyActiveAdmin_test.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON RubyActiveAdmin_test.active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON RubyActiveAdmin_test.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON RubyActiveAdmin_test.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON RubyActiveAdmin_test.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON RubyActiveAdmin_test.active_storage_blobs USING btree (key);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON RubyActiveAdmin_test.admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON RubyActiveAdmin_test.admin_users USING btree (reset_password_token);


--
-- Name: index_admin_users_on_role; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_admin_users_on_role ON RubyActiveAdmin_test.admin_users USING btree (role);


--
-- Name: index_dcd_on_dcc_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_dcd_on_dcc_id ON RubyActiveAdmin_test.doubt_chat_doubts USING btree (doubt_chat_channel_id);


--
-- Name: index_dcd_on_dcu_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_dcd_on_dcu_id ON RubyActiveAdmin_test.doubt_chat_doubts USING btree (doubt_chat_user_id);


--
-- Name: index_dcda_on_dcd_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_dcda_on_dcd_id ON RubyActiveAdmin_test.doubt_chat_doubt_answers USING btree (doubt_chat_doubt_id);


--
-- Name: index_dcda_on_dcu_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_dcda_on_dcu_id ON RubyActiveAdmin_test.doubt_chat_doubt_answers USING btree (doubt_chat_user_id);


--
-- Name: index_doubt_admins_on_admin_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_doubt_admins_on_admin_user_id ON RubyActiveAdmin_test.doubt_admins USING btree (admin_user_id);


--
-- Name: index_doubt_admins_on_doubtId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "index_doubt_admins_on_doubtId" ON RubyActiveAdmin_test.doubt_admins USING btree ("doubtId");


--
-- Name: index_doubt_chat_doubt_answers_on_ancestry; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_doubt_chat_doubt_answers_on_ancestry ON RubyActiveAdmin_test.doubt_chat_doubt_answers USING btree (ancestry);


--
-- Name: index_student_coaches_on_studentId_and_coachId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "index_student_coaches_on_studentId_and_coachId" ON RubyActiveAdmin_test.student_coaches USING btree ("studentId", "coachId");


--
-- Name: index_user_actions_on_userId; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "index_user_actions_on_userId" ON RubyActiveAdmin_test.user_actions USING btree ("userId");


--
-- Name: index_version_associations_on_foreign_key; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_version_associations_on_foreign_key ON RubyActiveAdmin_test.version_associations USING btree (foreign_key_name, foreign_key_id, foreign_type);


--
-- Name: index_version_associations_on_version_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_version_associations_on_version_id ON RubyActiveAdmin_test.version_associations USING btree (version_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON RubyActiveAdmin_test.versions USING btree (item_type, item_id);


--
-- Name: index_versions_on_transaction_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_versions_on_transaction_id ON RubyActiveAdmin_test.versions USING btree (transaction_id);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_vote_scope; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_votes_on_votable_id_and_votable_type_and_vote_scope ON RubyActiveAdmin_test.votes USING btree (votable_id, votable_type, vote_scope);


--
-- Name: index_votes_on_votable_type_and_votable_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_votes_on_votable_type_and_votable_id ON RubyActiveAdmin_test.votes USING btree (votable_type, votable_id);


--
-- Name: index_votes_on_voter_id_and_voter_type_and_vote_scope; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_votes_on_voter_id_and_voter_type_and_vote_scope ON RubyActiveAdmin_test.votes USING btree (voter_id, voter_type, vote_scope);


--
-- Name: index_votes_on_voter_type_and_voter_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX index_votes_on_voter_type_and_voter_id ON RubyActiveAdmin_test.votes USING btree (voter_type, voter_id);


--
-- Name: motivation_message_unique; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX motivation_message_unique ON RubyActiveAdmin_test."Motivation" USING btree (message);


--
-- Name: notification_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX notification_user_id ON RubyActiveAdmin_test."Notification" USING btree ("userId");


--
-- Name: question_deleted; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX question_deleted ON RubyActiveAdmin_test."Question" USING btree (deleted);


--
-- Name: question_gin_idx; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--
CREATE EXTENSION pg_trgm WITH schema RubyActiveAdmin_test; 
CREATE INDEX question_gin_idx ON RubyActiveAdmin_test."Question" USING gin (question RubyActiveAdmin_test.gin_trgm_ops);


--
-- Name: question_subTopic_question_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "question_subTopic_question_id" ON RubyActiveAdmin_test."QuestionSubTopic" USING btree ("questionId");


--
-- Name: question_subTopic_subTopic_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "question_subTopic_subTopic_id" ON RubyActiveAdmin_test."QuestionSubTopic" USING btree ("subTopicId");


--
-- Name: s_e_o_data_owner_id_owner_type; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX s_e_o_data_owner_id_owner_type ON RubyActiveAdmin_test."SEOData" USING btree ("ownerId", "ownerType");


--
-- Name: scheduled_task_course_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX scheduled_task_course_id ON RubyActiveAdmin_test."ScheduledTask" USING btree ("courseId");


--
-- Name: scheduled_task_expired_at; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX scheduled_task_expired_at ON RubyActiveAdmin_test."ScheduledTask" USING btree ("expiredAt");


--
-- Name: scheduled_task_scheduled_at; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX scheduled_task_scheduled_at ON RubyActiveAdmin_test."ScheduledTask" USING btree ("scheduledAt");


--
-- Name: scheduled_task_task_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX scheduled_task_task_id ON RubyActiveAdmin_test."ScheduledTask" USING btree ("taskId");


--
-- Name: scheduled_task_year; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX scheduled_task_year ON RubyActiveAdmin_test."ScheduledTask" USING btree (year);


--
-- Name: single_applicable_course_offer_constraint; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX single_applicable_course_offer_constraint ON RubyActiveAdmin_test."CourseOffer" USING btree ("courseId", email, "offerExpiryAt", title);


--
-- Name: studentnoteuniquencerthighlight; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX studentnoteuniquencerthighlight ON RubyActiveAdmin_test."StudentNote" USING btree ("userId", "noteId", details);


--
-- Name: subject_chapter_chapter_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX subject_chapter_chapter_id ON RubyActiveAdmin_test."SubjectChapter" USING btree ("chapterId");


--
-- Name: subject_chapter_deleted; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX subject_chapter_deleted ON RubyActiveAdmin_test."SubjectChapter" USING btree (deleted);


--
-- Name: subject_chapter_subject_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX subject_chapter_subject_id ON RubyActiveAdmin_test."SubjectChapter" USING btree ("subjectId");


--
-- Name: subject_leader_board_subject_id3; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX subject_leader_board_subject_id3 ON RubyActiveAdmin_test."SubjectLeaderBoard" USING btree ("subjectId");


--
-- Name: subject_leader_board_user_id_subject_id3; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX subject_leader_board_user_id_subject_id3 ON RubyActiveAdmin_test."SubjectLeaderBoard" USING btree ("subjectId", "userId");


--
-- Name: tagExist10; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "tagExist10" ON RubyActiveAdmin_test."QuestionAnalytics25" USING btree ("tagExist");


--
-- Name: task_course_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX task_course_id ON RubyActiveAdmin_test."Task" USING btree ("courseId");


--
-- Name: task_expired_at; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX task_expired_at ON RubyActiveAdmin_test."Task" USING btree ("expiredAt");


--
-- Name: task_parent_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX task_parent_id ON RubyActiveAdmin_test."Task" USING btree ("parentId");


--
-- Name: task_scheduled_at; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX task_scheduled_at ON RubyActiveAdmin_test."Task" USING btree ("scheduledAt");


--
-- Name: task_year; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX task_year ON RubyActiveAdmin_test."Task" USING btree (year);


--
-- Name: testAttempt_postmartem_testAttempt_id_user_id_question_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX "testAttempt_postmartem_testAttempt_id_user_id_question_id" ON RubyActiveAdmin_test."TestAttemptPostmartem" USING btree ("testAttemptId", "userId", "questionId");


--
-- Name: test_attempt_test_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX test_attempt_test_id ON RubyActiveAdmin_test."TestAttempt" USING btree ("testId");


--
-- Name: test_attempt_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX test_attempt_user_id ON RubyActiveAdmin_test."TestAttempt" USING btree ("userId");


--
-- Name: test_creator_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX test_creator_id ON RubyActiveAdmin_test."Test" USING btree ("creatorId");


--
-- Name: test_leader_board_test_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX test_leader_board_test_id ON RubyActiveAdmin_test."TestLeaderBoard" USING btree ("testId");


--
-- Name: test_leader_board_user_id_test_attempt_id_test_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX test_leader_board_user_id_test_attempt_id_test_id ON RubyActiveAdmin_test."TestLeaderBoard" USING btree ("userId", "testId", "testAttemptId");


--
-- Name: test_leader_board_user_id_test_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX test_leader_board_user_id_test_id ON RubyActiveAdmin_test."TestLeaderBoard" USING btree ("testId", "userId");


--
-- Name: test_owner_id_owner_type; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX test_owner_id_owner_type ON RubyActiveAdmin_test."Test" USING btree ("ownerId", "ownerType");


--
-- Name: test_question_question_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX test_question_question_id ON RubyActiveAdmin_test."TestQuestion" USING btree ("questionId");


--
-- Name: test_question_test_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX test_question_test_id ON RubyActiveAdmin_test."TestQuestion" USING btree ("testId");


--
-- Name: topic_asset_asset_id_asset_type; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX topic_asset_asset_id_asset_type ON RubyActiveAdmin_test."TopicAssetOld" USING btree ("assetId", "assetType");


--
-- Name: topic_asset_deleted; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX topic_asset_deleted ON RubyActiveAdmin_test."TopicAssetOld" USING btree (deleted);


--
-- Name: topic_asset_owner_id_owner_type; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX topic_asset_owner_id_owner_type ON RubyActiveAdmin_test."TopicAssetOld" USING btree ("ownerId", "ownerType");


--
-- Name: topic_asset_topic_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX topic_asset_topic_id ON RubyActiveAdmin_test."TopicAssetOld" USING btree ("topicId");


--
-- Name: topic_leader_board_topic_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX topic_leader_board_topic_id ON RubyActiveAdmin_test."TopicLeaderBoard" USING btree ("topicId");


--
-- Name: topic_leader_board_user_id_topic_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX topic_leader_board_user_id_topic_id ON RubyActiveAdmin_test."TopicLeaderBoard" USING btree ("userId", "topicId");


--
-- Name: user_course_invitation_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_course_invitation_id ON RubyActiveAdmin_test."UserCourse" USING btree ("invitationId");


--
-- Name: user_doubt_stat_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX user_doubt_stat_id ON RubyActiveAdmin_test."UserDoubtStat" USING btree (id);


--
-- Name: user_email; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_email ON RubyActiveAdmin_test."User" USING btree (email);


--
-- Name: user_highlighted_note_note_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_highlighted_note_note_id ON RubyActiveAdmin_test."UserHighlightedNote" USING btree ("noteId");


--
-- Name: user_highlighted_note_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_highlighted_note_user_id ON RubyActiveAdmin_test."UserHighlightedNote" USING btree ("userId");


--
-- Name: user_note_stat_note_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_note_stat_note_id ON RubyActiveAdmin_test."UserNoteStat" USING btree ("noteId");


--
-- Name: user_note_stat_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_note_stat_user_id ON RubyActiveAdmin_test."UserNoteStat" USING btree ("userId");


--
-- Name: user_phone; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_phone ON RubyActiveAdmin_test."User" USING btree (phone);


--
-- Name: user_profile_analytics_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX user_profile_analytics_user_id ON RubyActiveAdmin_test."UserProfileAnalytic" USING btree ("userId");


--
-- Name: user_profile_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX user_profile_user_id ON RubyActiveAdmin_test."UserProfile" USING btree ("userId");


--
-- Name: user_scheduled_task_scheduled_task_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_scheduled_task_scheduled_task_id ON RubyActiveAdmin_test."UserScheduledTask" USING btree ("scheduledTaskId");


--
-- Name: user_scheduled_task_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_scheduled_task_user_id ON RubyActiveAdmin_test."UserScheduledTask" USING btree ("userId");


--
-- Name: user_scheduled_task_user_id_scheduled_task_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX user_scheduled_task_user_id_scheduled_task_id ON RubyActiveAdmin_test."UserScheduledTask" USING btree ("userId", "scheduledTaskId");


--
-- Name: user_task_progress_user_id_schedule_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX user_task_progress_user_id_schedule_id ON RubyActiveAdmin_test."UserTaskProgress" USING btree ("userId", "scheduleId");


--
-- Name: user_task_task_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_task_task_id ON RubyActiveAdmin_test."UserTask" USING btree ("taskId");


--
-- Name: user_task_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_task_user_id ON RubyActiveAdmin_test."UserTask" USING btree ("userId");


--
-- Name: user_task_user_id_task_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE UNIQUE INDEX user_task_user_id_task_id ON RubyActiveAdmin_test."UserTask" USING btree ("userId", "taskId");


--
-- Name: user_video_stat_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_video_stat_user_id ON RubyActiveAdmin_test."UserVideoStat" USING btree ("userId");


--
-- Name: user_video_stat_video_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX user_video_stat_video_id ON RubyActiveAdmin_test."UserVideoStat" USING btree ("videoId");


--
-- Name: video_link_video_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX video_link_video_id ON RubyActiveAdmin_test."VideoLink" USING btree ("videoId");


--
-- Name: video_question_question_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX video_question_question_id ON RubyActiveAdmin_test."VideoQuestion" USING btree ("questionId");


--
-- Name: video_question_video_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX video_question_video_id ON RubyActiveAdmin_test."VideoQuestion" USING btree ("videoId");


--
-- Name: video_subTopic_subTopic_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "video_subTopic_subTopic_id" ON RubyActiveAdmin_test."VideoSubTopic" USING btree ("subTopicId");


--
-- Name: video_subTopic_video_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX "video_subTopic_video_id" ON RubyActiveAdmin_test."VideoSubTopic" USING btree ("videoId");


--
-- Name: video_test_test_id_video_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX video_test_test_id_video_id ON RubyActiveAdmin_test."VideoTest" USING btree ("testId", "videoId");


--
-- Name: vote_owner_id_owner_type; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX vote_owner_id_owner_type ON RubyActiveAdmin_test."Vote" USING btree ("ownerId", "ownerType");


--
-- Name: vote_user_id; Type: INDEX; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE INDEX vote_user_id ON RubyActiveAdmin_test."Vote" USING btree ("userId");


--
-- Name: VideoSubTopicQuestion _RETURN; Type: RULE; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE OR REPLACE VIEW RubyActiveAdmin_test."VideoSubTopicQuestion" AS
 SELECT "Question".id,
    "VideoSubTopic"."videoId",
    "Question".id AS "questionId"
   FROM RubyActiveAdmin_test."Question",
    RubyActiveAdmin_test."QuestionSubTopic",
    RubyActiveAdmin_test."VideoSubTopic",
    RubyActiveAdmin_test."QuestionAnalytics",
    RubyActiveAdmin_test."ChapterQuestion",
    RubyActiveAdmin_test."SubTopic",
    RubyActiveAdmin_test."Topic",
    RubyActiveAdmin_test."SubjectChapter",
    RubyActiveAdmin_test."Subject"
  WHERE (("VideoSubTopic"."subTopicId" = "QuestionSubTopic"."subTopicId") AND ("Question".id = "QuestionSubTopic"."questionId") AND ("Question".id = "QuestionAnalytics".id) AND ("QuestionAnalytics"."difficultyLevel" = 'easy'::text) AND ("Question".deleted = false) AND ("Question".type = ANY (ARRAY['MCQ-SO'::RubyActiveAdmin_test."enum_Question_type", 'MCQ-AR'::RubyActiveAdmin_test."enum_Question_type"])) AND ("QuestionSubTopic"."subTopicId" = "SubTopic".id) AND ("SubTopic"."topicId" = "ChapterQuestion"."chapterId") AND ("ChapterQuestion"."questionId" = "Question".id) AND ("Topic".id = "ChapterQuestion"."chapterId") AND ("SubjectChapter"."chapterId" = "Topic".id) AND ("Subject".id = "SubjectChapter"."subjectId") AND ("Subject"."courseId" = 8));


--
-- Name: TestAttempt test_attempt_history_update; Type: TRIGGER; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TRIGGER test_attempt_history_update AFTER UPDATE ON RubyActiveAdmin_test."TestAttempt" FOR EACH ROW EXECUTE PROCEDURE RubyActiveAdmin_test.test_attempt_history_update();


--
-- Name: test test_history_delete; Type: TRIGGER; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TRIGGER test_history_delete AFTER DELETE ON RubyActiveAdmin_test.test FOR EACH ROW EXECUTE PROCEDURE RubyActiveAdmin_test.history_delete();


--
-- Name: test test_history_insert; Type: TRIGGER; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TRIGGER test_history_insert AFTER INSERT ON RubyActiveAdmin_test.test FOR EACH ROW EXECUTE PROCEDURE RubyActiveAdmin_test.history_insert();


--
-- Name: test test_history_update; Type: TRIGGER; Schema: RubyActiveAdmin_test; Owner: -
--

CREATE TRIGGER test_history_update AFTER UPDATE ON RubyActiveAdmin_test.test FOR EACH ROW EXECUTE PROCEDURE RubyActiveAdmin_test.history_update();


--
-- Name: Answer Answer_questionId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Answer"
    ADD CONSTRAINT "Answer_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Answer Answer_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Answer"
    ADD CONSTRAINT "Answer_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChapterMindmap ChapterMindmap_chapterId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterMindmap"
    ADD CONSTRAINT "ChapterMindmap_chapterId_fkey" FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: ChapterMindmap ChapterMindmap_noteId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterMindmap"
    ADD CONSTRAINT "ChapterMindmap_noteId_fkey" FOREIGN KEY ("noteId") REFERENCES RubyActiveAdmin_test."Note"(id);


--
-- Name: Comment Comment_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Comment"
    ADD CONSTRAINT "Comment_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CourseOffer CourseOffer_admin_user_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseOffer"
    ADD CONSTRAINT "CourseOffer_admin_user_id_fkey" FOREIGN KEY (admin_user_id) REFERENCES RubyActiveAdmin_test.admin_users(id);


--
-- Name: CourseOffer CourseOffer_courseId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseOffer"
    ADD CONSTRAINT "CourseOffer_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES RubyActiveAdmin_test."Course"(id);


--
-- Name: CourseTestimonial CourseTestimonial_courseId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseTestimonial"
    ADD CONSTRAINT "CourseTestimonial_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES RubyActiveAdmin_test."Course"(id);


--
-- Name: CustomerIssue CustomerIssue_typeId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue"
    ADD CONSTRAINT "CustomerIssue_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES RubyActiveAdmin_test."CustomerIssueType"(id);


--
-- Name: CustomerIssue CustomerIssue_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue"
    ADD CONSTRAINT "CustomerIssue_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: DailyUserEvent DailyUserEvent_courseId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DailyUserEvent"
    ADD CONSTRAINT "DailyUserEvent_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES RubyActiveAdmin_test."Course"(id);


--
-- Name: DailyUserEvent DailyUserEvent_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DailyUserEvent"
    ADD CONSTRAINT "DailyUserEvent_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: DoubtAnswer DoubtAnswer_doubtId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DoubtAnswer"
    ADD CONSTRAINT "DoubtAnswer_doubtId_fkey" FOREIGN KEY ("doubtId") REFERENCES RubyActiveAdmin_test."Doubt"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DoubtAnswer DoubtAnswer_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."DoubtAnswer"
    ADD CONSTRAINT "DoubtAnswer_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt Doubt_topicId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Doubt"
    ADD CONSTRAINT "Doubt_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES RubyActiveAdmin_test."Topic"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt Doubt_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Doubt"
    ADD CONSTRAINT "Doubt_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: NCERTQuestion NCERTQuestion_questionId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."NCERTQuestion"
    ADD CONSTRAINT "NCERTQuestion_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: Payment Payment_courseOfferId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Payment"
    ADD CONSTRAINT "Payment_courseOfferId_fkey" FOREIGN KEY ("courseOfferId") REFERENCES RubyActiveAdmin_test."CourseOffer"(id);


--
-- Name: Payment Payment_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Payment"
    ADD CONSTRAINT "Payment_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuestionCourse QuestionCourse_courseId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionCourse"
    ADD CONSTRAINT "QuestionCourse_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES RubyActiveAdmin_test."Course"(id);


--
-- Name: QuestionCourse QuestionCourse_questionId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionCourse"
    ADD CONSTRAINT "QuestionCourse_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: QuestionTranslation QuestionTranslation_newQuestionId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionTranslation"
    ADD CONSTRAINT "QuestionTranslation_newQuestionId_fkey" FOREIGN KEY ("newQuestionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: QuestionTranslation QuestionTranslation_questionId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionTranslation"
    ADD CONSTRAINT "QuestionTranslation_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: Question Question_creatorId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Question"
    ADD CONSTRAINT "Question_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Question Question_subjectId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Question"
    ADD CONSTRAINT "Question_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES RubyActiveAdmin_test."Subject"(id);


--
-- Name: StudentNote StudentNote_noteId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."StudentNote"
    ADD CONSTRAINT "StudentNote_noteId_fkey" FOREIGN KEY ("noteId") REFERENCES RubyActiveAdmin_test."Note"(id);


--
-- Name: StudentNote StudentNote_videoId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."StudentNote"
    ADD CONSTRAINT "StudentNote_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES RubyActiveAdmin_test."Video"(id);


--
-- Name: Subject Subject_courseId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Subject"
    ADD CONSTRAINT "Subject_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES RubyActiveAdmin_test."Course"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Topic Topic_subjectId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Topic"
    ADD CONSTRAINT "Topic_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES RubyActiveAdmin_test."Subject"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserClaim UserClaim_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserClaim"
    ADD CONSTRAINT "UserClaim_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserCourse UserCourse_courseId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserCourse"
    ADD CONSTRAINT "UserCourse_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES RubyActiveAdmin_test."Course"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserCourse UserCourse_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserCourse"
    ADD CONSTRAINT "UserCourse_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserProfile UserProfile_userId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserProfile"
    ADD CONSTRAINT "UserProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: VideoAnnotation VideoAnnotation_videoId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoAnnotation"
    ADD CONSTRAINT "VideoAnnotation_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES RubyActiveAdmin_test."Video"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: VideoTest VideoTest_testId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoTest"
    ADD CONSTRAINT "VideoTest_testId_fkey" FOREIGN KEY ("testId") REFERENCES RubyActiveAdmin_test."Test"(id);


--
-- Name: VideoTest VideoTest_videoId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoTest"
    ADD CONSTRAINT "VideoTest_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES RubyActiveAdmin_test."Video"(id);


--
-- Name: Video Video_creatorId_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Video"
    ADD CONSTRAINT "Video_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_note_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue"
    ADD CONSTRAINT customer_issue_note_id_fkey FOREIGN KEY ("noteId") REFERENCES RubyActiveAdmin_test."Note"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_question_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue"
    ADD CONSTRAINT customer_issue_question_id_fkey FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_test_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue"
    ADD CONSTRAINT customer_issue_test_id_fkey FOREIGN KEY ("testId") REFERENCES RubyActiveAdmin_test."Test"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_topic_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue"
    ADD CONSTRAINT customer_issue_topic_id_fkey FOREIGN KEY ("topicId") REFERENCES RubyActiveAdmin_test."Topic"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerIssue customer_issue_video_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerIssue"
    ADD CONSTRAINT customer_issue_video_id_fkey FOREIGN KEY ("videoId") REFERENCES RubyActiveAdmin_test."Video"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt doubt_note_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Doubt"
    ADD CONSTRAINT doubt_note_id_fkey FOREIGN KEY ("noteId") REFERENCES RubyActiveAdmin_test."Note"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt doubt_question_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Doubt"
    ADD CONSTRAINT doubt_question_id_fkey FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Doubt doubt_test_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Doubt"
    ADD CONSTRAINT doubt_test_id_fkey FOREIGN KEY ("testId") REFERENCES RubyActiveAdmin_test."Test"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FcmToken fcm_token_user_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."FcmToken"
    ADD CONSTRAINT fcm_token_user_id_fkey FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChapterNote fk_chapter_note_chapterid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterNote"
    ADD CONSTRAINT fk_chapter_note_chapterid FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: ChapterNote fk_chapter_note_noteid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterNote"
    ADD CONSTRAINT fk_chapter_note_noteid FOREIGN KEY ("noteId") REFERENCES RubyActiveAdmin_test."Note"(id);


--
-- Name: ChapterQuestion fk_chapter_question_chapterid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterQuestion"
    ADD CONSTRAINT fk_chapter_question_chapterid FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: ChapterQuestionCopy fk_chapter_question_chapterid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterQuestionCopy"
    ADD CONSTRAINT fk_chapter_question_chapterid FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: ChapterQuestion fk_chapter_question_questionid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterQuestion"
    ADD CONSTRAINT fk_chapter_question_questionid FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: ChapterQuestionCopy fk_chapter_question_questionid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterQuestionCopy"
    ADD CONSTRAINT fk_chapter_question_questionid FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: ChapterTask fk_chapter_task_chapterid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTask"
    ADD CONSTRAINT fk_chapter_task_chapterid FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: ChapterTask fk_chapter_task_taskid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTask"
    ADD CONSTRAINT fk_chapter_task_taskid FOREIGN KEY ("taskId") REFERENCES RubyActiveAdmin_test."Task"(id);


--
-- Name: ChapterTest fk_chapter_test_chapterid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTest"
    ADD CONSTRAINT fk_chapter_test_chapterid FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: ChapterTest fk_chapter_test_testid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterTest"
    ADD CONSTRAINT fk_chapter_test_testid FOREIGN KEY ("testId") REFERENCES RubyActiveAdmin_test."Test"(id);


--
-- Name: ChapterVideo fk_chapter_video_chapterid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterVideo"
    ADD CONSTRAINT fk_chapter_video_chapterid FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: ChapterVideo fk_chapter_video_videoid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterVideo"
    ADD CONSTRAINT fk_chapter_video_videoid FOREIGN KEY ("videoId") REFERENCES RubyActiveAdmin_test."Video"(id);


--
-- Name: CourseTest fk_course_test_courseid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseTest"
    ADD CONSTRAINT fk_course_test_courseid FOREIGN KEY ("courseId") REFERENCES RubyActiveAdmin_test."Course"(id);


--
-- Name: CourseTest fk_course_test_testid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseTest"
    ADD CONSTRAINT fk_course_test_testid FOREIGN KEY ("testId") REFERENCES RubyActiveAdmin_test."Test"(id);


--
-- Name: QuestionSubTopic fk_question_subtopic_questionid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionSubTopic"
    ADD CONSTRAINT fk_question_subtopic_questionid FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: QuestionSubTopic fk_question_subtopic_subtopicid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."QuestionSubTopic"
    ADD CONSTRAINT fk_question_subtopic_subtopicid FOREIGN KEY ("subTopicId") REFERENCES RubyActiveAdmin_test."SubTopic"(id);


--
-- Name: Test fk_rails_016fa67182; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Test"
    ADD CONSTRAINT fk_rails_016fa67182 FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: UserTodo fk_rails_058d2d272e; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserTodo"
    ADD CONSTRAINT fk_rails_058d2d272e FOREIGN KEY ("subjectId") REFERENCES RubyActiveAdmin_test."Subject"(id);


--
-- Name: CourseDetail fk_rails_259449bff2; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseDetail"
    ADD CONSTRAINT fk_rails_259449bff2 FOREIGN KEY ("courseId") REFERENCES RubyActiveAdmin_test."Course"(id);


--
-- Name: user_actions fk_rails_2796d61ea0; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.user_actions
    ADD CONSTRAINT fk_rails_2796d61ea0 FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: UserTodo fk_rails_2f3b933224; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserTodo"
    ADD CONSTRAINT fk_rails_2f3b933224 FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: UserTodo fk_rails_322f64ccd2; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserTodo"
    ADD CONSTRAINT fk_rails_322f64ccd2 FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: CustomerSupport fk_rails_334df1fef4; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CustomerSupport"
    ADD CONSTRAINT fk_rails_334df1fef4 FOREIGN KEY ("adminUserId") REFERENCES RubyActiveAdmin_test.admin_users(id);


--
-- Name: CourseInvitation fk_rails_52b958d86d; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."CourseInvitation"
    ADD CONSTRAINT fk_rails_52b958d86d FOREIGN KEY (admin_user_id) REFERENCES RubyActiveAdmin_test.admin_users(id);


--
-- Name: StudentOnboardingEvents fk_rails_57a5cd7155; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."StudentOnboardingEvents"
    ADD CONSTRAINT fk_rails_57a5cd7155 FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: doubt_chat_doubt_answers fk_rails_5cb473102b; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_chat_doubt_answers
    ADD CONSTRAINT fk_rails_5cb473102b FOREIGN KEY (doubt_chat_doubt_id) REFERENCES RubyActiveAdmin_test.doubt_chat_doubts(id);


--
-- Name: student_coaches fk_rails_5d22b2e06e; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.student_coaches
    ADD CONSTRAINT fk_rails_5d22b2e06e FOREIGN KEY ("studentId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: Section fk_rails_69f13a1696; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Section"
    ADD CONSTRAINT fk_rails_69f13a1696 FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: student_coaches fk_rails_88f9034dec; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.student_coaches
    ADD CONSTRAINT fk_rails_88f9034dec FOREIGN KEY ("coachId") REFERENCES RubyActiveAdmin_test.admin_users(id);


--
-- Name: ChapterFlashCard fk_rails_9414c57a02; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterFlashCard"
    ADD CONSTRAINT fk_rails_9414c57a02 FOREIGN KEY ("flashCardId") REFERENCES RubyActiveAdmin_test."FlashCard"(id);


--
-- Name: ChapterFlashCard fk_rails_951f27dd9a; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterFlashCard"
    ADD CONSTRAINT fk_rails_951f27dd9a FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: UserFlashCard fk_rails_997fa74b62; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserFlashCard"
    ADD CONSTRAINT fk_rails_997fa74b62 FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: ChapterGlossary fk_rails_99bcc2b2ef; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterGlossary"
    ADD CONSTRAINT fk_rails_99bcc2b2ef FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: UserFlashCard fk_rails_9a2726adae; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserFlashCard"
    ADD CONSTRAINT fk_rails_9a2726adae FOREIGN KEY ("flashCardId") REFERENCES RubyActiveAdmin_test."FlashCard"(id);


--
-- Name: version_associations fk_rails_a20d5f0c08; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.version_associations
    ADD CONSTRAINT fk_rails_a20d5f0c08 FOREIGN KEY (version_id) REFERENCES RubyActiveAdmin_test.versions(id);


--
-- Name: doubt_admins fk_rails_a317c597bf; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_admins
    ADD CONSTRAINT fk_rails_a317c597bf FOREIGN KEY ("doubtId") REFERENCES RubyActiveAdmin_test."Doubt"(id);


--
-- Name: Target fk_rails_a57307e52b; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Target"
    ADD CONSTRAINT fk_rails_a57307e52b FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: TargetChapter fk_rails_acd040cb85; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TargetChapter"
    ADD CONSTRAINT fk_rails_acd040cb85 FOREIGN KEY ("chapterId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: UserResult fk_rails_b38a96ebdf; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserResult"
    ADD CONSTRAINT fk_rails_b38a96ebdf FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: ChapterGlossary fk_rails_b426e0b75b; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ChapterGlossary"
    ADD CONSTRAINT fk_rails_b426e0b75b FOREIGN KEY ("glossaryId") REFERENCES RubyActiveAdmin_test."Glossary"(id);


--
-- Name: doubt_chat_doubts fk_rails_b5b3bf45b3; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.doubt_chat_doubts
    ADD CONSTRAINT fk_rails_b5b3bf45b3 FOREIGN KEY (doubt_chat_channel_id) REFERENCES RubyActiveAdmin_test.doubt_chat_channels(id);


--
-- Name: TargetChapter fk_rails_b94a981115; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TargetChapter"
    ADD CONSTRAINT fk_rails_b94a981115 FOREIGN KEY ("targetId") REFERENCES RubyActiveAdmin_test."Target"(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES RubyActiveAdmin_test.active_storage_blobs(id);


--
-- Name: SectionContent fk_rails_ccea17349b; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."SectionContent"
    ADD CONSTRAINT fk_rails_ccea17349b FOREIGN KEY ("sectionId") REFERENCES RubyActiveAdmin_test."Section"(id);


--
-- Name: ScheduleItem fk_schedule_item_schedule; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItem"
    ADD CONSTRAINT fk_schedule_item_schedule FOREIGN KEY ("scheduleId") REFERENCES RubyActiveAdmin_test."Schedule"(id);


--
-- Name: ScheduleItem fk_schedule_item_topic; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItem"
    ADD CONSTRAINT fk_schedule_item_topic FOREIGN KEY ("topicId") REFERENCES RubyActiveAdmin_test."Topic"(id);


--
-- Name: ScheduleItemUser fk_schedule_item_user_schedule_item; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItemUser"
    ADD CONSTRAINT fk_schedule_item_user_schedule_item FOREIGN KEY ("scheduleItemId") REFERENCES RubyActiveAdmin_test."ScheduleItem"(id);


--
-- Name: ScheduleItemUser fk_schedule_item_user_user; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."ScheduleItemUser"
    ADD CONSTRAINT fk_schedule_item_user_user FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: TestQuestion fk_test_question_questionid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TestQuestion"
    ADD CONSTRAINT fk_test_question_questionid FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: TestQuestion fk_test_question_testid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."TestQuestion"
    ADD CONSTRAINT fk_test_question_testid FOREIGN KEY ("testId") REFERENCES RubyActiveAdmin_test."Test"(id);


--
-- Name: UserLogin fk_user_login_user; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserLogin"
    ADD CONSTRAINT fk_user_login_user FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id);


--
-- Name: VideoQuestion fk_video_question_questionid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoQuestion"
    ADD CONSTRAINT fk_video_question_questionid FOREIGN KEY ("questionId") REFERENCES RubyActiveAdmin_test."Question"(id);


--
-- Name: VideoQuestion fk_video_question_videoid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoQuestion"
    ADD CONSTRAINT fk_video_question_videoid FOREIGN KEY ("videoId") REFERENCES RubyActiveAdmin_test."Video"(id);


--
-- Name: VideoSubTopic fk_video_subtopic_subtopicid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoSubTopic"
    ADD CONSTRAINT fk_video_subtopic_subtopicid FOREIGN KEY ("subTopicId") REFERENCES RubyActiveAdmin_test."Video"(id);


--
-- Name: VideoSubTopic fk_video_subtopic_videoid; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."VideoSubTopic"
    ADD CONSTRAINT fk_video_subtopic_videoid FOREIGN KEY ("videoId") REFERENCES RubyActiveAdmin_test."Video"(id);


--
-- Name: UserCourse invitationId_fk; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."UserCourse"
    ADD CONSTRAINT "invitationId_fk" FOREIGN KEY ("invitationId") REFERENCES RubyActiveAdmin_test."CourseInvitation"(id) ON DELETE CASCADE;


--
-- Name: Notification notification_user_id_fkey; Type: FK CONSTRAINT; Schema: RubyActiveAdmin_test; Owner: -
--

ALTER TABLE ONLY RubyActiveAdmin_test."Notification"
    ADD CONSTRAINT notification_user_id_fkey FOREIGN KEY ("userId") REFERENCES RubyActiveAdmin_test."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO google_ads,RubyActiveAdmin_test;

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
('20201221113137');


