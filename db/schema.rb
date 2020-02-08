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

ActiveRecord::Schema.define(version: 2020_02_07_121248) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_repack"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

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
    t.integer "questionId"
    t.integer "userId"
    t.integer "testAttemptId"
    t.integer "durationInSec"
    t.string "incorrectAnswerReason", limit: 255
    t.text "incorrectAnswerOther"
    t.index ["incorrectAnswerReason"], name: "answer_incorrect_answer_reason"
    t.index ["testAttemptId"], name: "answer_test_attempt_id"
    t.index ["userId", "questionId"], name: "answer_user_id_question_id", unique: true
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
    t.integer "questionId"
    t.integer "userId"
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
    t.integer "chapterId"
    t.integer "questionId"
    t.datetime "createdAt", default: -> { "now()" }, null: false
    t.datetime "updatedAt", default: -> { "now()" }, null: false
    t.index ["chapterId", "questionId"], name: "chapterquestion1_chapter_id_question_id", unique: true
    t.index ["chapterId"], name: "chapter_question_chapter_id"
    t.index ["questionId"], name: "chapter_question_question_id"
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
    t.integer "chapterId"
    t.integer "testId"
    t.datetime "createdAt", default: -> { "now()" }, null: false
    t.datetime "updatedAt", default: -> { "now()" }, null: false
    t.index ["chapterId", "testId"], name: "chaptertest_chapter_id_test_id", unique: true
    t.index ["chapterId"], name: "chapter_test_chapter_id"
    t.index ["testId"], name: "chapter_test_test_id"
  end

  create_table "ChapterVideo", id: :serial, force: :cascade do |t|
    t.integer "chapterId"
    t.integer "videoId"
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

  create_table "CopyAnswer", id: :serial, force: :cascade do |t|
    t.integer "userAnswer"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "questionId"
    t.integer "userId"
    t.integer "testAttemptId"
    t.integer "durationInSec"
  end

# Could not dump table "CopyQuestion01012019" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

# Could not dump table "CopyQuestion010120191" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

# Could not dump table "CopyQuestion29092018" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

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

  create_table "CourseTest", id: :serial, force: :cascade do |t|
    t.integer "courseId"
    t.integer "testId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["courseId"], name: "course_test_course_id"
    t.index ["testId"], name: "course_test_test_id"
  end

  create_table "CustomerIssue", id: :serial, force: :cascade do |t|
    t.text "description", null: false
    t.integer "typeId", null: false
    t.integer "questionId"
    t.integer "videoId"
    t.integer "noteId"
    t.integer "topicId", null: false
    t.boolean "deleted", default: false
    t.boolean "resolved", default: false
    t.integer "userId", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
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

