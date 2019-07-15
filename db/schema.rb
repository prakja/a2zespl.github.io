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

ActiveRecord::Schema.define(version: 2019_07_12_115059) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_repack"
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

  create_table "ChapterNote", id: :serial, force: :cascade do |t|
    t.integer "chapterId"
    t.integer "noteId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "ChapterQuestion", id: :serial, force: :cascade do |t|
    t.integer "chapterId"
    t.integer "questionId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["chapterId"], name: "chapter_question_chapter_id"
    t.index ["questionId"], name: "chapter_question_question_id"
  end

  create_table "ChapterTask", id: :serial, force: :cascade do |t|
    t.integer "chapterId"
    t.integer "taskId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "ChapterVideo", id: :serial, force: :cascade do |t|
    t.integer "chapterId"
    t.integer "videoId"
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
    t.index ["fcmToken"], name: "fcmtoken_unique", unique: true
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

  create_table "Group", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.string "description", limit: 255
    t.boolean "deleted", default: false
    t.datetime "startedAt", null: false
    t.datetime "expiryAt", null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
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
    t.datetime "createdAt"
    t.datetime "updatedAt"
    t.boolean "highIntent", default: false
    t.index ["url"], name: "Post_url_key", unique: true
  end

# Could not dump table "Question" because of following StandardError
#   Unknown type '"enum_Question_type"' for column 'type'

  create_table "QuestionDetail", id: :serial, force: :cascade do |t|
    t.integer "year"
    t.string "exam", limit: 255
    t.text "examName"
    t.integer "questionId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
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
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["ownerId", "ownerType"], name: "s_e_o_data_owner_id_owner_type", unique: true
  end

  create_table "Schedule", id: :serial, force: :cascade do |t|
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.text "name"
    t.text "description"
  end

  create_table "ScheduleItem", id: :serial, force: :cascade do |t|
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.text "name"
    t.text "description"
    t.integer "scheduleId", null: false
    t.integer "topicId", null: false
    t.integer "hours"
    t.text "link"
    t.datetime "scheduledAt"
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

  create_table "SequelizeMeta", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
  end

  create_table "SubTopic", id: :serial, force: :cascade do |t|
    t.integer "topicId"
    t.string "name", limit: 255
    t.boolean "deleted"
    t.integer "position"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
  end

  create_table "Subject", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "image"
    t.text "description"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "courseId"
  end

  create_table "SubjectChapter", id: :serial, force: :cascade do |t|
    t.integer "subjectId"
    t.integer "chapterId"
    t.boolean "deleted"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["chapterId"], name: "subject_chapter_chapter_id"
    t.index ["deleted"], name: "subject_chapter_deleted"
    t.index ["subjectId"], name: "subject_chapter_subject_id"
  end

  create_table "Task", id: :serial, force: :cascade do |t|
    t.integer "parentId"
    t.integer "courseId"
    t.integer "seqId"
    t.text "title"
    t.text "link"
    t.text "desc"
    t.decimal "duration", precision: 5, scale: 2
    t.integer "year"
    t.datetime "scheduledAt"
    t.datetime "expiredAt"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "liveSeqId2019"
    t.integer "liveSeqId2020"
    t.integer "level"
    t.index ["courseId"], name: "task_course_id"
    t.index ["expiredAt"], name: "task_expired_at"
    t.index ["parentId"], name: "task_parent_id"
    t.index ["scheduledAt"], name: "task_scheduled_at"
    t.index ["year"], name: "task_year"
  end

# Could not dump table "Test" because of following StandardError
#   Unknown type '"enum_Test_exam"' for column 'exam'

  create_table "TestAttempt", id: :serial, force: :cascade do |t|
    t.integer "testId"
    t.integer "userId"
    t.integer "elapsedDurationInSec", default: 0
    t.integer "currentQuestionOffset", default: 0
    t.boolean "completed", default: false
    t.json "userAnswers"
    t.json "userQuestionWiseDurationInSec"
    t.json "result"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.json "visitedQuestions"
    t.json "markedQuestions"
    t.index ["testId"], name: "test_attempt_test_id"
    t.index ["userId"], name: "test_attempt_user_id"
  end

  create_table "Topic", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "image"
    t.text "description"
    t.integer "position"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "subjectId"
    t.boolean "free", default: false, null: false
    t.boolean "published", default: false, null: false
    t.integer "seqId", default: 0, null: false
    t.string "importUrl", limit: 255
    t.boolean "isComingSoon", default: false
  end

  create_table "TopicAsset", id: :serial, force: :cascade do |t|
    t.string "assetType", limit: 255
    t.integer "assetId"
    t.integer "topicId"
    t.integer "position"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.boolean "deleted", default: false
    t.integer "ownerId", null: false
    t.string "ownerType", limit: 255, null: false
    t.index ["assetId", "assetType"], name: "topic_asset_asset_id_asset_type"
    t.index ["deleted"], name: "topic_asset_deleted"
    t.index ["ownerId", "ownerType"], name: "topic_asset_owner_id_owner_type"
    t.index ["topicId"], name: "topic_asset_topic_id"
  end

  create_table "User", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.boolean "emailConfirmed", default: false
    t.text "hashedPassword"
    t.text "phone"
    t.boolean "phoneConfirmed", default: false
    t.text "provider"
    t.string "role", limit: 20, default: "student"
    t.string "salt", limit: 32
    t.text "resetPasswordToken"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "referrerId"
    t.string "fcmToken", limit: 255
    t.text "source"
    t.text "referrer"
    t.boolean "isFcmTokenActive", default: true
    t.boolean "blockedUser", default: false
    t.index ["email"], name: "User_email_key", unique: true
    t.index ["email"], name: "user_email"
    t.index ["phone"], name: "User_phone_key", unique: true
    t.index ["phone"], name: "user_phone"
  end

  create_table "UserClaim", id: :serial, force: :cascade do |t|
    t.string "type", limit: 255
    t.string "value", limit: 255
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "userId"
  end

# Could not dump table "UserCourse" because of following StandardError
#   Unknown type '"enum_UserCourse_role"' for column 'role'

  create_table "UserHighlightedNote", id: :serial, force: :cascade do |t|
    t.integer "userId", null: false
    t.integer "noteId", null: false
    t.string "content", limit: 1000
    t.string "color", limit: 255
    t.string "rangy", limit: 255
    t.string "cfiRange", limit: 255
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.string "userNote", limit: 255
    t.integer "pageNumber"
    t.string "pageId", limit: 255
    t.string "uuid", limit: 255
    t.boolean "deleted", default: false
    t.index ["noteId"], name: "user_highlighted_note_note_id"
    t.index ["userId"], name: "user_highlighted_note_user_id"
  end

  create_table "UserLogin", id: :serial, force: :cascade do |t|
    t.integer "userId", null: false
    t.integer "expiry", null: false
    t.string "platform", limit: 255, null: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["userId", "platform"], name: "u_user_id_platform", unique: true
  end

  create_table "UserNoteStat", id: :serial, force: :cascade do |t|
    t.integer "userId", null: false
    t.integer "noteId", null: false
    t.integer "lastReadPage"
    t.boolean "completed", default: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.string "bookId", limit: 255
    t.string "chapterHref", limit: 255
    t.boolean "usingId"
    t.string "value", limit: 255
    t.string "cfi", limit: 255
    t.index ["noteId"], name: "user_note_stat_note_id"
    t.index ["userId", "noteId"], name: "usernotestat_user_id_note_id", unique: true
    t.index ["userId"], name: "user_note_stat_user_id"
  end

  create_table "UserProfile", id: :serial, force: :cascade do |t|
    t.string "displayName", limit: 100
    t.text "picture"
    t.string "gender", limit: 50
    t.string "location", limit: 100
    t.string "website", limit: 255
    t.string "firstName", limit: 100
    t.string "lastName", limit: 100
    t.string "address", limit: 100
    t.string "city", limit: 100
    t.string "country", limit: 100
    t.string "intro", limit: 1000
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "userId"
    t.integer "defaultCourseId"
    t.string "email", limit: 255
    t.string "phone", limit: 20
    t.integer "neetExamYear"
    t.json "weeklySchedule"
    t.decimal "dailyStudyHours", precision: 4, scale: 2
    t.string "registrationNumber", limit: 255
    t.date "dob"
    t.string "neetAdmitCard", limit: 255
    t.text "utmCampaignMedium"
    t.text "utmCampaignSource"
    t.text "utmCampaignLink"
    t.text "utmAdNetwork"
    t.text "utmCampaignTerm"
    t.text "utmCampaignContent"
    t.text "utmCampaignName"
    t.json "campaignInfo"
    t.index ["userId"], name: "user_profile_user_id", unique: true
  end

  create_table "UserScheduledTask", id: :serial, force: :cascade do |t|
    t.integer "userId"
    t.integer "scheduledTaskId"
    t.decimal "duration", precision: 5, scale: 2
    t.boolean "completed", default: false
    t.boolean "started", default: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["scheduledTaskId"], name: "user_scheduled_task_scheduled_task_id"
    t.index ["userId", "scheduledTaskId"], name: "user_scheduled_task_user_id_scheduled_task_id", unique: true
    t.index ["userId"], name: "user_scheduled_task_user_id"
  end

  create_table "UserTask", id: :serial, force: :cascade do |t|
    t.integer "userId"
    t.integer "taskId"
    t.decimal "duration", precision: 5, scale: 2
    t.decimal "userDuration", precision: 5, scale: 2
    t.boolean "completed", default: false
    t.boolean "started", default: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["taskId"], name: "user_task_task_id"
    t.index ["userId", "taskId"], name: "user_task_user_id_task_id", unique: true
    t.index ["userId"], name: "user_task_user_id"
  end

  create_table "UserVideoStat", id: :serial, force: :cascade do |t|
    t.integer "userId"
    t.integer "videoId"
    t.float "lastPosition"
    t.boolean "completed", default: false
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["userId", "videoId"], name: "uservideostat_user_id_video_id", unique: true
    t.index ["userId"], name: "user_video_stat_user_id"
    t.index ["videoId"], name: "user_video_stat_video_id"
  end

  create_table "Video", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.text "url"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "creatorId"
    t.text "thumbnail"
    t.float "duration"
    t.integer "seqId", default: 0, null: false
    t.string "youtubeUrl", limit: 255
  end

  create_table "VideoAnnotation", id: :serial, force: :cascade do |t|
    t.string "annotationType", limit: 255
    t.integer "annotationId"
    t.integer "videoId"
    t.integer "videoTimeStampInSeconds"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer "videoTimeMS", null: false
  end

  create_table "VideoQuestion", id: :serial, force: :cascade do |t|
    t.integer "videoId"
    t.integer "questionId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["questionId"], name: "video_question_question_id"
    t.index ["videoId"], name: "video_question_video_id"
  end

  create_table "VideoSubTopic", id: :serial, force: :cascade do |t|
    t.integer "videoId"
    t.integer "subTopicId"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["subTopicId"], name: "video_subTopic_subTopic_id"
    t.index ["videoId"], name: "video_subTopic_video_id"
  end

  create_table "Vote", id: :serial, force: :cascade do |t|
    t.integer "userId"
    t.integer "ownerId"
    t.string "ownerType", limit: 255
    t.boolean "vote"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.index ["ownerId", "ownerType"], name: "vote_owner_id_owner_type"
    t.index ["userId"], name: "vote_user_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "read", null: false
    t.string "name"
    t.integer "userId"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "question_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "Answer", "\"Question\"", column: "questionId", name: "Answer_questionId_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "Answer", "\"User\"", column: "userId", name: "Answer_userId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "ChapterNote", "\"Note\"", column: "noteId", name: "fk_chapter_note_note_id"
  add_foreign_key "ChapterNote", "\"Topic\"", column: "chapterId", name: "fk_chapter_note_chapterid"
  add_foreign_key "ChapterQuestion", "\"Question\"", column: "questionId", name: "fk_chapter_question_questionid"
  add_foreign_key "ChapterQuestion", "\"Topic\"", column: "chapterId", name: "fk_chapter_question_chapterid"
  add_foreign_key "ChapterTask", "\"Task\"", column: "taskId", name: "fk_chapter_task_taskid"
  add_foreign_key "ChapterTask", "\"Topic\"", column: "chapterId", name: "fk_chapter_task_chapterid"
  add_foreign_key "ChapterVideo", "\"Topic\"", column: "chapterId", name: "fk_chapter_video_chapterid"
  add_foreign_key "ChapterVideo", "\"Video\"", column: "videoId", name: "fk_chapter_video_videoid"
  add_foreign_key "Comment", "\"User\"", column: "userId", name: "Comment_userId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "CourseTest", "\"Course\"", column: "courseId", name: "fk_course_test_courseid"
  add_foreign_key "CourseTest", "\"Test\"", column: "testId", name: "fk_course_test_testid"
  add_foreign_key "CustomerIssue", "\"CustomerIssueType\"", column: "typeId", name: "CustomerIssue_typeId_fkey"
  add_foreign_key "CustomerIssue", "\"Note\"", column: "noteId", name: "customer_issue_note_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "CustomerIssue", "\"Question\"", column: "questionId", name: "customer_issue_question_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "CustomerIssue", "\"Topic\"", column: "topicId", name: "customer_issue_topic_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "CustomerIssue", "\"User\"", column: "userId", name: "CustomerIssue_userId_fkey"
  add_foreign_key "CustomerIssue", "\"Video\"", column: "videoId", name: "customer_issue_video_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Doubt", "\"Note\"", column: "noteId", name: "doubt_note_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Doubt", "\"Question\"", column: "questionId", name: "doubt_question_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Doubt", "\"Test\"", column: "testId", name: "doubt_test_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Doubt", "\"Topic\"", column: "topicId", name: "Doubt_topicId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Doubt", "\"User\"", column: "userId", name: "Doubt_userId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "DoubtAnswer", "\"Doubt\"", column: "doubtId", name: "DoubtAnswer_doubtId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "DoubtAnswer", "\"User\"", column: "userId", name: "DoubtAnswer_userId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "FcmToken", "\"User\"", column: "userId", name: "fcm_token_user_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Notification", "\"User\"", column: "userId", name: "notification_user_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Payment", "\"User\"", column: "userId", name: "Payment_userId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Question", "\"Test\"", column: "testId", name: "Question_testId_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "Question", "\"User\"", column: "creatorId", name: "Question_creatorId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "QuestionSubTopic", "\"Question\"", column: "questionId", name: "fk_question_subtopic_questionid"
  add_foreign_key "QuestionSubTopic", "\"Question\"", column: "subTopicId", name: "fk_question_subtopic_subtopicid"
  add_foreign_key "ScheduleItem", "\"Schedule\"", column: "scheduleId", name: "fk_schedule_item_schedule"
  add_foreign_key "ScheduleItem", "\"Topic\"", column: "topicId", name: "fk_schedule_item_topic"
  add_foreign_key "ScheduleItemUser", "\"ScheduleItem\"", column: "scheduleItemId", name: "fk_schedule_item_user_schedule_item"
  add_foreign_key "ScheduleItemUser", "\"User\"", column: "userId", name: "fk_schedule_item_user_user"
  add_foreign_key "Subject", "\"Course\"", column: "courseId", name: "Subject_courseId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Topic", "\"Subject\"", column: "subjectId", name: "Topic_subjectId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "UserClaim", "\"User\"", column: "userId", name: "UserClaim_userId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "UserCourse", "\"Course\"", column: "courseId", name: "UserCourse_courseId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "UserCourse", "\"User\"", column: "userId", name: "UserCourse_userId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "UserLogin", "\"User\"", column: "userId", name: "fk_user_login_user"
  add_foreign_key "UserProfile", "\"User\"", column: "userId", name: "UserProfile_userId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "Video", "\"User\"", column: "creatorId", name: "Video_creatorId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "VideoAnnotation", "\"Video\"", column: "videoId", name: "VideoAnnotation_videoId_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "VideoQuestion", "\"Question\"", column: "questionId", name: "fk_video_question_questionid"
  add_foreign_key "VideoQuestion", "\"Video\"", column: "videoId", name: "fk_video_question_videoid"
  add_foreign_key "VideoSubTopic", "\"Video\"", column: "subTopicId", name: "fk_video_subtopic_subtopicid"
  add_foreign_key "VideoSubTopic", "\"Video\"", column: "videoId", name: "fk_video_subtopic_videoid"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
