# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_09_072958) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_repack"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "ActiveFlashCardChapter", force: :cascade do |t|
    t.integer "chapterId"
  end

# Could not dump table "Advertisement" because of following StandardError
#   Unknown type '"enum_Advertisement_platform"' for column 'platform'

  create_table "Announcement", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "content"
    t.integer "userId"
    t.integer "courseId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["courseId"], name: "announcement_course_id"
    t.index ["userId"], name: "announcement_user_id"
  end

  create_table "Answer", id: :serial, force: :cascade do |t|
    t.integer "userAnswer"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "questionId", null: false
    t.integer "userId", null: false
    t.integer "testAttemptId"
    t.integer "durationInSec"
    t.string "incorrectAnswerReason", limit: 255
    t.text "incorrectAnswerOther"
    t.index ["incorrectAnswerReason"], name: "answer_incorrect_answer_reason"
    t.index ["testAttemptId"], name: "answer_test_attempt_id"
    t.index ["userId", "questionId", "testAttemptId"], name: "answer_user_id_question_id_test_attempt_id", unique: true
  end

  create_table "AppVersion", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "version", limit: 255
    t.text "description"
    t.boolean "forceUpdate"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "BookmarkQuestion", id: :serial, force: :cascade do |t|
    t.integer "questionId", null: false
    t.integer "userId", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["questionId"], name: "bookmark_question_question_id"
    t.index ["userId", "questionId"], name: "bookmarkquestion_user_id_question_id", unique: true
    t.index ["userId"], name: "bookmark_question_user_id"
  end

  create_table "CAMPAIGN_PERFORMANCE_REPORT", primary_key: "__sdc_primary_key", id: :text, force: :cascade do |t|
    t.datetime "_sdc_batched_at"
    t.text "_sdc_customer_id"
    t.datetime "_sdc_extracted_at"
    t.datetime "_sdc_received_at"
    t.datetime "_sdc_report_datetime"
    t.bigint "_sdc_sequence"
    t.bigint "_sdc_table_version"
    t.bigint "avgCost"
    t.bigint "bidStrategyID"
    t.text "bidStrategyType"
    t.bigint "budget"
    t.bigint "budgetID"
    t.text "campaign"
    t.bigint "campaignID"
    t.text "campaignState"
    t.text "campaignTrialType"
    t.float "convRate"
    t.float "conversions"
    t.bigint "cost"
    t.bigint "costConv"
    t.text "currency"
    t.datetime "day"
    t.bigint "impressions"
    t.float "interactionRate"
    t.bigint "interactions"
  end

  create_table "ChapterFlashCard", force: :cascade do |t|
    t.integer "chapterId", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "flashCardId", null: false
    t.integer "seqId"
    t.index ["chapterId", "flashCardId"], name: "ChapterFlashCard_chapterId_flashCardId_idx", unique: true
    t.index ["chapterId"], name: "ChapterFlashCard_chapterId_idx"
    t.index ["flashCardId"], name: "ChapterFlashCard_flashCardId_idx"
  end

  create_table "ChapterNote", id: :serial, force: :cascade do |t|
    t.integer "chapterId"
    t.integer "noteId"
    t.datetime "createdAt", default: -> { "now()" }, null: false
    t.datetime "updatedAt", default: -> { "now()" }, null: false
    t.index ["chapterId", "noteId"], name: "chapternote_chapter_id_note_id", unique: true
    t.index ["chapterId"], name: "chapter_note_chapter_id"
    t.index ["noteId"], name: "chapter_note_note_id"
  end

  create_table "ChapterQuestion", id: :serial, force: :cascade do |t|
    t.integer "chapterId", null: false
    t.integer "questionId", null: false
    t.datetime "createdAt", default: -> { "now()" }, null: false
    t.datetime "updatedAt", default: -> { "now()" }, null: false
    t.index ["chapterId", "questionId"], name: "chapterquestion1_chapter_id_question_id", unique: true
    t.index ["chapterId"], name: "chapter_question_chapter_id"
    t.index ["questionId"], name: "chapter_question_question_id"
  end

  create_table "ChapterQuestion20200516", id: false, force: :cascade do |t|
    t.integer "id"
    t.integer "chapterId"
    t.integer "questionId"
    t.datetime "createdAt"
    t.datetime "updatedAt"
  end

  create_table "ChapterQuestion20200528", id: false, force: :cascade do |t|
    t.integer "id"
    t.integer "chapterId"
    t.integer "questionId"
    t.datetime "createdAt"
    t.datetime "updatedAt"
  end

  create_table "ChapterQuestionCopy", id: false, force: :cascade do |t|
    t.integer "id", default: -> { "nextval('\"ChapterQuestion_id_seq\"'::regclass)" }, null: false
    t.integer "chapterId"
    t.integer "questionId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["chapterId", "questionId"], name: "chapterquestion_chapter_id_question_id", unique: true
  end

  create_table "ChapterTask", id: :serial, force: :cascade do |t|
    t.integer "chapterId"
    t.integer "taskId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["chapterId"], name: "chapter_task_chapter_id"
    t.index ["taskId"], name: "chapter_task_task_id"
  end

  create_table "ChapterTest", id: :serial, force: :cascade do |t|
    t.integer "chapterId", null: false
    t.integer "testId", null: false
    t.datetime "createdAt", default: -> { "now()" }, null: false
    t.datetime "updatedAt", default: -> { "now()" }, null: false
    t.index ["chapterId", "testId"], name: "chaptertest_chapter_id_test_id", unique: true
    t.index ["chapterId"], name: "chapter_test_chapter_id"
    t.index ["testId"], name: "chapter_test_test_id"
  end

  create_table "ChapterVideo", id: :serial, force: :cascade do |t|
    t.integer "chapterId", null: false
    t.integer "videoId", null: false
    t.datetime "createdAt", default: -> { "now()" }, null: false
    t.datetime "updatedAt", default: -> { "now()" }, null: false
    t.index ["chapterId", "videoId"], name: "chaptervideo_chapter_id_video_id", unique: true
    t.index ["chapterId"], name: "chapter_video_chapter_id"
    t.index ["videoId"], name: "chapter_video_video_id"
  end

  create_table "ChatAnswer", id: :serial, force: :cascade do |t|
    t.integer "userAnswer"
    t.integer "questionId", null: false
    t.integer "messageId"
    t.integer "groupId"
    t.integer "userId", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "Comment", id: :serial, force: :cascade do |t|
    t.text "text"
    t.text "imgUrl"
    t.string "ownerType", limit: 255
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "ownerId"
    t.integer "userId"
  end

  create_table "ConfigValue", id: :serial, force: :cascade do |t|
    t.text "accessToken"
    t.string "refreshToken", limit: 255
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "CopyAnswer", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.integer "userAnswer"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "questionId"
    t.integer "userId"
    t.integer "testAttemptId"
    t.integer "durationInSec"
  end

  create_table "CopyNote", id: false, force: :cascade do |t|
    t.integer "id"
    t.string "name", limit: 255
    t.text "content"
    t.text "description"
    t.integer "creatorId"
    t.datetime "createdAt"
    t.datetime "updatedAt"
    t.text "externalURL"
    t.text "epubURL"
    t.text "epubContent"
  end

# Could not dump table "CopyQuestion01012019" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

# Could not dump table "CopyQuestion010120191" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

# Could not dump table "CopyQuestion20200504" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

# Could not dump table "CopyQuestion29092018" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

  create_table "CopySubjectChapter", id: false, force: :cascade do |t|
    t.integer "id"
    t.integer "subjectId"
    t.integer "chapterId"
    t.boolean "deleted"
    t.datetime "createdAt"
    t.datetime "updatedAt"
  end

  create_table "CopyTestAttempt", id: :serial, force: :cascade do |t|
    t.integer "testId"
    t.integer "userId"
    t.integer "elapsedDurationInSec"
    t.integer "currentQuestionOffset"
    t.boolean "completed"
    t.json "userAnswers"
    t.json "userQuestionWiseDurationInSec"
    t.json "result"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.json "visitedQuestions"
    t.json "markedQuestions"
  end

# Could not dump table "Coupon" because of following StandardError
#   Unknown type '"enum_Coupon_discountType"' for column 'discountType'

# Could not dump table "Course" because of following StandardError
#   Unknown type '"enum_Course_package"' for column 'package'

# Could not dump table "CourseInvitation" because of following StandardError
#   Unknown type '"enum_CourseInvitation_role"' for column 'role'

  create_table "CourseOffer", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "description"
    t.integer "courseId", null: false
    t.decimal "fee", precision: 10, scale: 2, null: false
    t.decimal "discountedFee", precision: 10, scale: 2
    t.string "email", limit: 255
    t.string "phone", limit: 255
    t.datetime "expiryAt"
    t.integer "durationInDays"
    t.datetime "offerExpiryAt"
    t.datetime "offerStartedAt"
    t.integer "admin_user_id"
    t.boolean "hidden", default: false, null: false
    t.integer "position"
    t.datetime "createdAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updatedAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["courseId"], name: "course_offer_course_id"
  end

  create_table "CourseTest", id: :serial, force: :cascade do |t|
    t.integer "courseId", null: false
    t.integer "testId", null: false
    t.datetime "createdAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updatedAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["courseId"], name: "course_test_course_id"
    t.index ["testId"], name: "course_test_test_id"
  end

  create_table "CustomerIssue", id: :serial, force: :cascade do |t|
    t.text "description", null: false
    t.integer "typeId", null: false
    t.integer "questionId"
    t.integer "videoId"
    t.integer "noteId"
    t.integer "topicId"
    t.boolean "deleted", default: false
    t.boolean "resolved", default: false
    t.integer "userId", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "testId"
    t.index ["questionId"], name: "CustomerIssue_questionId_idx"
    t.index ["videoId"], name: "CustomerIssue_videoId_idx"
  end

  create_table "CustomerIssueType", id: :serial, force: :cascade do |t|
    t.string "code", limit: 255, null: false
    t.string "displayName", limit: 255, null: false
    t.text "description", null: false
    t.string "focusArea", limit: 255, null: false
    t.boolean "deleted", default: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["code"], name: "CustomerIssueType_code_key", unique: true
  end

  create_table "CustomerSupport", id: :serial, force: :cascade do |t|
    t.integer "userId", null: false
    t.string "content", limit: 255
    t.string "phone", limit: 255
    t.string "issueType", limit: 255
    t.boolean "deleted", default: false
    t.boolean "resolved", default: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.string "email"
    t.string "userData"
    t.integer "adminUserId"
  end

  create_table "Delivery", id: :serial, force: :cascade do |t|
    t.string "deliveryType", limit: 255
    t.string "course", limit: 255
    t.datetime "courseValidity"
    t.integer "amount"
    t.string "source", limit: 255
    t.datetime "purchasedAt"
    t.string "name", limit: 255
    t.string "mobile", limit: 255
    t.text "address"
    t.string "counselorName", limit: 255
    t.string "trackingNumber", limit: 255
    t.string "usb", limit: 255
    t.string "dongle", limit: 255
    t.boolean "delivered"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.string "purchasedAtText", limit: 255
    t.string "installmentAmount", limit: 255
    t.boolean "packed"
    t.text "description"
    t.string "email", limit: 255
    t.string "courierSource", limit: 255
    t.datetime "dueDate"
    t.integer "dueAmount"
    t.string "status", limit: 255
  end

# Could not dump table "Doubt" because of following StandardError
#   Unknown type '"enum_Doubt_doubtType"' for column 'doubtType'

  create_table "DoubtAnswer", id: :serial, force: :cascade do |t|
    t.text "content"
    t.text "imgUrl"
    t.boolean "accepted"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "doubtId"
    t.integer "userId"
    t.boolean "deleted", default: false
    t.index ["doubtId"], name: "Doubt_answer_doubt_id"
    t.index ["userId"], name: "Doubt_answer_user_id"
  end

  create_table "DuplicateChapter", id: :serial, force: :cascade do |t|
    t.integer "origId", null: false
    t.integer "dupId", null: false
    t.index ["dupId"], name: "DuplicateChapter_dupId_idx"
    t.index ["origId", "dupId"], name: "unique_origId_dupId", unique: true
    t.index ["origId"], name: "DuplicateChapter_origId_idx"
  end

  create_table "DuplicatePost", id: :serial, force: :cascade do |t|
    t.integer "postId", null: false
    t.text "content"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "FcmToken", id: :serial, force: :cascade do |t|
    t.string "fcmToken", limit: 255, null: false
    t.string "deviceId", limit: 255
    t.string "androidDetails", limit: 255
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "userId"
    t.string "platform", limit: 255
    t.string "deviceAdsId", limit: 255
  end

  create_table "FestivalDiscount", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "description"
    t.boolean "flag", default: true, null: false
    t.datetime "startDate", null: false
    t.datetime "endDate", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "FlashCard", force: :cascade do |t|
    t.string "content"
    t.string "title"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "Group", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.string "description", limit: 255
    t.datetime "startedAt", null: false
    t.datetime "expiryAt", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.string "liveSessionUrl", limit: 255
  end

  create_table "Installment", id: :serial, force: :cascade do |t|
    t.integer "paymentId", null: false
    t.datetime "secondInstallmentDate"
    t.integer "secondInstallmentAmount"
    t.datetime "finalInstallmentDate"
    t.integer "finalInstallmentAmount"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

# Could not dump table "Message" because of following StandardError
#   Unknown type '"enum_Message_type"' for column 'type'

  create_table "Motivation", id: :serial, force: :cascade do |t|
    t.text "message", null: false
    t.string "author", limit: 255
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["message"], name: "motivation_message_unique", unique: true
  end

  create_table "NEETExamResult", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.date "dob"
    t.string "nationality", limit: 100
    t.integer "score"
    t.integer "rank"
    t.string "state", limit: 50
    t.integer "year"
    t.integer "stateRank"
    t.string "category", limit: 20
  end

  create_table "NewUserVideoStat", id: false, force: :cascade do |t|
    t.integer "id"
    t.integer "userId"
    t.integer "videoId"
    t.float "lastPosition"
    t.boolean "completed"
    t.datetime "createdAt"
    t.datetime "updatedAt"
  end

  create_table "Note", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "content"
    t.text "description"
    t.integer "creatorId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.text "externalURL"
    t.text "epubURL"
    t.text "epubContent"
  end

  create_table "Notification", id: :serial, force: :cascade do |t|
    t.integer "userId"
    t.integer "contextId"
    t.string "contextType", limit: 255
    t.text "title"
    t.text "body"
    t.text "actionUrl"
    t.string "senderName", limit: 255
    t.string "senderEmail", limit: 255
    t.datetime "scheduledAt"
    t.boolean "sendEmail"
    t.boolean "sendAppNotification"
    t.boolean "sendWebNotification"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.text "imgUrl"
    t.index ["userId"], name: "notification_user_id"
  end

  create_table "OldCourseTest", id: :serial, force: :cascade do |t|
    t.integer "courseId"
    t.integer "testId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

# Could not dump table "Payment" because of following StandardError
#   Unknown type '"enum_Payment_status"' for column 'status'

  create_table "PaymentCourseInvitation", id: :serial, force: :cascade do |t|
    t.integer "paymentId", null: false
    t.integer "courseInvitationId", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "Post", id: :serial, force: :cascade do |t|
    t.text "url", null: false
    t.text "title", null: false
    t.text "description", null: false
    t.text "section_1"
    t.text "section_2"
    t.text "section_3"
    t.text "section_4"
    t.datetime "createdAt", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updatedAt", default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "highIntent", default: false
    t.index ["url"], name: "Post_url_key", unique: true
  end

# Could not dump table "Question" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

# Could not dump table "Question20200516" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

# Could not dump table "Question20201305" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

  create_table "QuestionDetail", id: :serial, force: :cascade do |t|
    t.integer "year"
    t.string "exam", limit: 255
    t.text "examName"
    t.integer "questionId"
    t.datetime "createdAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updatedAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["questionId"], name: "QuestionDetail_questionId"
  end

  create_table "QuestionExplanation", id: :serial, force: :cascade do |t|
    t.integer "questionId"
    t.text "explanation"
    t.string "language", limit: 255
    t.integer "courseId"
    t.boolean "deleted"
    t.integer "position"
    t.datetime "createdAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updatedAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["courseId"], name: "QuestionExplanation_courseId_idx"
    t.index ["questionId"], name: "QuestionExplanation_questionId_idx"
  end

  create_table "QuestionExplanation20200516", id: false, force: :cascade do |t|
    t.integer "id"
    t.integer "questionId"
    t.text "explanation"
    t.string "language", limit: 255
    t.integer "courseId"
    t.boolean "deleted"
    t.integer "position"
    t.datetime "createdAt"
    t.datetime "updatedAt"
  end

  create_table "QuestionSubTopic", id: :serial, force: :cascade do |t|
    t.integer "questionId"
    t.integer "subTopicId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["questionId"], name: "question_subTopic_question_id"
    t.index ["subTopicId"], name: "question_subTopic_subTopic_id"
  end

  create_table "Quiz", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.integer "timeRequiredInSeconds"
    t.integer "creatorId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "SEOData", id: :serial, force: :cascade do |t|
    t.integer "ownerId"
    t.string "ownerType", limit: 255
    t.text "title"
    t.text "description"
    t.text "keywords"
    t.text "paragraph"
    t.datetime "createdAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updatedAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "ogImage", limit: 255
    t.index ["ownerId", "ownerType"], name: "s_e_o_data_owner_id_owner_type", unique: true
  end

  create_table "Schedule", id: :serial, force: :cascade do |t|
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.text "name"
    t.text "description"
    t.boolean "isActive"
  end

  create_table "ScheduleItem", id: :serial, force: :cascade do |t|
    t.datetime "createdAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updatedAt", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "name"
    t.text "description"
    t.integer "scheduleId", null: false
    t.integer "topicId"
    t.integer "hours"
    t.text "link"
    t.datetime "scheduledAt"
  end

  create_table "ScheduleItemAsset", force: :cascade do |t|
    t.bigint "ScheduleItem_id"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.text "assetLink"
    t.string "assetName"
    t.index ["ScheduleItem_id"], name: "index_ScheduleItemAsset_on_ScheduleItem_id"
  end

  create_table "ScheduleItemUser", id: :serial, force: :cascade do |t|
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "scheduleItemId", null: false
    t.integer "userId", null: false
    t.boolean "completed"
    t.index ["scheduleItemId", "userId"], name: "u_schedule_item_user_user", unique: true
  end

  create_table "ScheduledTask", id: :serial, force: :cascade do |t|
    t.integer "parentId"
    t.integer "courseId"
    t.text "title"
    t.text "link"
    t.text "desc"
    t.decimal "duration", precision: 5, scale: 2
    t.integer "year"
    t.datetime "scheduledAt"
    t.datetime "expiredAt"
    t.integer "taskId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["courseId"], name: "scheduled_task_course_id"
    t.index ["expiredAt"], name: "scheduled_task_expired_at"
    t.index ["scheduledAt"], name: "scheduled_task_scheduled_at"
    t.index ["taskId"], name: "scheduled_task_task_id"
    t.index ["year"], name: "scheduled_task_year"
  end

  create_table "Section", force: :cascade do |t|
    t.string "name", null: false
    t.integer "chapterId", null: false
    t.integer "position", default: 0
    t.string "ncertName"
    t.string "ncertURL"
    t.string "ncertSectionLink"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

