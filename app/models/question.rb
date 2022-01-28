require 'engtagger'

class Question < ApplicationRecord
  include ActiveModel::Dirty
  extend QuestionKeyword

  QUESTION_SET_TEST_IDS = [1020201, 1061903, 1061910, 1061913, 1061915, 1061925, 1061938, 1061940, 1061963, 1061965, 1061969, 1061976, 1061982, 1061988]

  QUESTION_TYPE_TEST_IDS = {
    :pyq => [384, 367, 383, 350, 359, 372, 366, 377, 370, 388, 398, 387, 396, 30571, 364364, 348, 45168, 347, 419],
    :ncert_back => [1020201],
    :test_series => [45310, 45311, 45312, 132501, 132507, 15256, 15257, 15258, 15259, 15260, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 15268, 15269, 15270, 15271, 56253, 56255, 944151],
    :already_selected => [1158021, 1155398, 1158181, 1158211, 1159044, 1159079, 1159266, 1159299, 1159390, 1159528, 1156678, 1156728, 1156846, 1155788, 1156768, 1157019, 1157090, 1157177, 1157854, 1157949, 1158085, 1158324, 1158356, 1158395, 1160741, 1161020, 1161121, 1161248, 116129, 1162167, 1162257, 1162306, 1162425, 1162961, 1163361, 1163423, 1163479, 1163851, 1163953, 1165162, 1165257, 1165313, 1165370, 1157849, 1157921, 1157965, 1158057, 1158104, 1155609, 1156486, 1156678, 1159338, 1158258, 1159146],
  }

  before_save :default_values
  after_save :update_question_bank_chapters

  def default_values
    self.options = ["(1)", "(2)", "(3)", "(4)"] if self.options.blank?
    self.level = nil if self.level.blank?
    # find subjectId to be populated
    if (not self.topicId.blank?)
      self.subjectId = SubjectChapter.where(chapterId: self.topicId, subjectId: [53,54,55,56,1214,1215,1216,1217]).limit(1).take()&.subjectId;
    end
    # replace s3 urls with cdn urls
    if (not self.explanation.blank?) and (self.explanation.include? 'https://questionexplanation.s3-us-west-2.amazonaws.com/' or self.explanation.include? 'https://learner-users.s3.ap-south-1.amazonaws.com/')
      self.explanation.gsub!("https://questionexplanation.s3-us-west-2.amazonaws.com/", "https://bcdna.neetprep.com/")
      self.explanation.gsub!("https://learner-users.s3.ap-south-1.amazonaws.com/", "https://bcdna1.neetprep.com/")
    end
  end
  has_paper_trail
  after_commit :after_update_question, if: Proc.new { |model| model.previous_changes[:correctOptionIndex]}, on: [:update]
  after_validation :check_correct_option_of_mcq_type_question

  def check_correct_option_of_mcq_type_question
    errors.add(:correctOptionIndex, 'is required field for mcq question') if type == 'MCQ-SO' and correctOptionIndex.blank?
  end

  def correctOption
    if not self.options.blank? and self.options.kind_of?(Array) and not self.correctOptionIndex.blank? and self.correctOptionIndex >= 0
      return self.options[self.correctOptionIndex]
    else
      return nil
    end
  end

  def has_video_solution
    self.explanation&.match(/<iframe .*(youtube|youtube-nocookie)\.com\/embed.*<\/iframe>/)
  end

  def update_question_bank_chapters
    if self.saved_change_to_topicId?
      self.update_chapter_questions!
    end
  end

  def update_chapter_questions!
    self.questionTopics.each do |chapter_question|
      chapter_question.update_chapter!(self.topicId)
    end
    ChapterQuestion.main_course_chapter_update!(self.id, self.topicId)
  end

  def insert_chapter_question
    ChapterQuestion.create!(chapterId: self.topicId, questionId: self.id)
  end

  def test_addition_validation
    errors.add(:type, 'mcq only questions can be added in tests') if type == 'SUBJECTIVE' and !tests.blank?
  end

  def after_update_question
    if self.tests.blank?
      return
    end

    HTTParty.post(
      Rails.configuration.node_site_url + "api/v1/webhook/afterUpdateQuestion",
        body: {
          id: self.id
    })
  end

  def set_image_link!
    payload = {
      "type": "Question",
      "id": self.id
    }
    token_lambda = JsonWebToken.encode_for_lambda(payload)
    HTTParty.post(Rails.application.config.create_image_url + '?query=' + token_lambda)
  end

  def abcd_options?
    return self.type=='MCQ-SO' && !((self.question=~/.*\(a\).*\(b\).*\(c\).*\(d\).*/im).nil?) && (self.question=~/.*1.*2.*3.*4.*/m).nil?
  end

  def num_options?
    return self.type=='MCQ-SO' && (self.question=~/.*\(a\).*\(b\).*\(c\).*\(d\).*/im).nil? && !((self.question=~/.*\(1\).*\(2\).*\(3\).*\(4\).*/m).nil?)
  end

  def convert_num_options
    self.question.sub!(/>\s*?\(a\)\s*?/i, '>(1)') and (self.question.sub!(/>\s*?\(b\)\s*?/i, '>(2)') or self.question.sub!(/\s*?\(b\)\s*?/i, '</p><p>(2)')) and (self.question.sub!(/>\s*?\(c\)\s*?/i, '>(3)') or self.question.sub!(/\s*?\(c\)\s*?/i, '</p><p>(3)')) and (self.question.sub!(/>\s*?\(d\)\s*?/i, '>(4)') or self.question.sub!(/\s*?\(d\)\s*?/i, '</p><p>(4)'))
  end

  def change_option_index!
    # rigour checks to ensure that we are very unlikely to do incorrect modification
    self.restore_attributes
    if self.abcd_options?
      if self.convert_num_options
        if self.num_options?
          self.options = ["(1)", "(2)", "(3)", "(4)"]
          self.explanation.sub!(/^<p>\((a|b|c|d)\)\.?/i, '<p>')
          self.save!
        end
      end
    end
  end
  
  self.table_name = "Question"
  self.inheritance_column = "QWERTY"
  default_scope {where(deleted: false)}
  attribute :createdAt, :datetime, default: -> { Time.now }
  attribute :updatedAt, :datetime, default: -> { Time.now }

  before_update :setUpdatedTime

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  scope :course_subject_id, ->(subject_id) {
    joins(:topics => :subjects).where(topics: {Subject: {id: subject_id}})
  }

  ransacker :ncertSentences_count do
    Arel.sql('(SELECT COUNT("QuestionNcertSentence"."id") FROM "QuestionNcertSentence" WHERE "QuestionNcertSentence"."questionId" = "Question"."id")')
  end

  ransacker :videoSentences_count do
    Arel.sql('(SELECT COUNT("QuestionVideoSentence"."id") FROM "QuestionVideoSentence" WHERE "QuestionVideoSentence"."questionId" = "Question"."id")')
  end

  ransacker :subTopics_count do
    Arel.sql('(SELECT COUNT("QuestionSubTopic"."id") FROM "QuestionSubTopic" WHERE "QuestionSubTopic"."questionId" = "Question"."id")')
  end

  ransacker :topics_count do
    Arel.sql('(SELECT COUNT("ChapterQuestion"."id") FROM "ChapterQuestion" WHERE "ChapterQuestion"."questionId" = "Question"."id")')
  end

  ransacker :course_tests_count do
    Arel.sql('(SELECT COUNT("TestQuestion"."id") FROM "TestQuestion", "Test", "CourseTest" WHERE "TestQuestion"."questionId" = "Question"."id" and "Test"."id" = "TestQuestion"."testId" and "Test"."userId" is null and exists(select "id" from "CourseTest" where "CourseTest"."testId" = "Test"."id"))')
  end

  scope :test_course_id, ->(course_id) {
    joins('INNER JOIN "CourseTestQuestion" ON "CourseTestQuestion"."questionId" = "Question"."id"').where('"courseId" = ' + course_id.to_s)
  }

  scope :course_id, ->(course_id) {
    joins(:topics => :subjects).where(topics: {Subject: {courseId: course_id}})
  }

  scope :course_name, ->(*course_ids) {
    flatten_course_ids = course_ids.flatten
    joins(:topics => :subjects).where(topics: {Subject: {courseId: flatten_course_ids}})
  }

  scope :has_ncert_sentences, ->() {
    Question.ransack({ncertSentences_count_gt: 0}).result
  }

  scope :no_ncert_sentences, ->() {
    Question.ransack({ncertSentences_count_eq: 0}).result
  }

  scope :has_video_sentences, ->() {
    Question.ransack({videoSentences_count_gt: 0}).result
  }

  scope :no_video_sentences, ->() {
    Question.ransack({videoSentences_count_eq: 0}).result
  }

  scope :subject_ids, ->(*subject_ids) {
    flatten_subject_ids = subject_ids.flatten
    joins(:topics => :subjects).where(topics: {Subject: {id: flatten_subject_ids}})
  }

  scope :subject_id, ->(subject_id) {
    joins(:topics => :subjects).where(topics: {Subject: {id: subject_id}})
  }

  scope :course_ids, ->(*course_ids) {
    flatten_course_ids = course_ids.flatten
    joins(:topics => :subjects).where(topics: {Subject: {courseId: flatten_course_ids}})
  }

  scope :similar_questions, ->(question_id) {
    question = Question.where('"topicId" is not null').find(question_id)
    if question.nil?
      raise "can't find duplicate for question with null topic id"
    end
    where('"Question"."topicId" = ? and similarity("question", (select "question" from "Question" t where t."id" = ?)) > 0.5 and not exists (select * from "NotDuplicateQuestion" where ("questionId1" = "Question"."id" and "questionId2" = ?) or ("questionId2" = "Question"."id" and "questionId1" = ?))', question.topicId, question_id, question_id, question_id);
  }

  scope :not_in_qb, -> {
    where('not exists (select * from "ChapterQuestion" where "ChapterQuestion"."chapterId" = "Question"."topicId" and "ChapterQuestion"."questionId" = "Question"."id") and not exists (select * from "ChapterQuestion" where "ChapterQuestion"."chapterId" = "Question"."topicId" and "ChapterQuestion"."questionId" in (select "questionId1" from "DuplicateQuestion" where "DuplicateQuestion"."questionId2" = "Question"."id")) and not exists (select * from "ChapterQuestion" where "ChapterQuestion"."chapterId" = "Question"."topicId" and "ChapterQuestion"."questionId" in (Select "questionId2" from "DuplicateQuestion" where "DuplicateQuestion"."questionId1" = "Question"."id"))')
  }

  scope :multiple_youtube, ->() {
    where('"explanation" like \'%youtu%youtu%\'')
  }

  scope :image_question, -> {
    neetprep_course.where('"question" like \'%img%amazonaws%\' and length(regexp_replace("question", \'<img.*?/>\', \'\')) <= 15')
  }

  scope :missing_subTopics, -> {
    left_outer_joins(:questionSubTopics).where('"QuestionSubTopic"."questionId" is null')
  }

  scope :missing_audio_explanation, -> {
    where('"explanation" not like \'%<audio%>%\'')
  }

  scope :missing_ncert_reference, -> {
    where('"explanation" not ilike \'%NCERT%\'')
  }

  scope :test_image_question, -> {
    neetprep_tests.where('"question" like \'%img%amazonaws%\' and length(regexp_replace("question", \'<img.*?/>\', \'\')) <= 15')
  }

  scope :topic, ->(topic_id) {
    joins(:topics).where("\"Topic\".\"id\"="+topic_id)
  }

  scope :difficult, -> {
    joins(:question_analytic).where("\"QuestionAnalytics\".\"difficultyLevel\" in ('medium','difficult')")
  }

  scope :easy, -> {
    joins(:question_analytic).where("\"QuestionAnalytics\".\"correctPercentage\" >= 60")
  }

  scope :easyLevel, -> {
    joins(:question_analytic).where("\"QuestionAnalytics\".\"difficultyLevel\" = 'easy'")
  }

  scope :mediumLevel, -> {
    joins(:question_analytic).where("\"QuestionAnalytics\".\"difficultyLevel\" = 'medium'")
  }

  scope :difficultLevel, -> {
    joins(:question_analytic).where("\"QuestionAnalytics\".\"difficultyLevel\" = 'difficult'")
  }

  scope :neetprep_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId: Rails.configuration.hinglish_full_course_id}})}
  scope :not_neetprep_course, -> {left_outer_joins(:topics => :subject).where(topics: {Subject: {courseId: nil}})}
  scope :bio_masterclass_course, -> {joins(:topics => :subject).where(topics: {Subject: {courseId: Rails.configuration.bio_masterclass_course_id}})}
  scope :neetprep_tests, -> {joins(:tests => :topics).where(tests: {Topic: {subjectId: [53,54,55,56]}})}

  scope :physics_mcqs, -> {where(subjectId: 55)}
  scope :physics_mcqs_difficult, ->(topic_id) {
    subject_id(55).topic(topic_id).difficult
  }
  scope :chemistry_mcqs_difficult, ->(topic_id) {
    subject_id(54).topic(topic_id).difficult
  }
  scope :botany_mcqs_difficult, ->(topic_id) {
    subject_id(53).topic(topic_id).difficult
  }
  scope :zoology_mcqs_difficult, ->(topic_id) {
    subject_id(56).topic(topic_id).difficult
  }
  scope :empty_explanation, -> {where('LENGTH("Question"."explanation") < 30')}
  scope :short_explanation, -> {where('LENGTH("Question"."explanation") < 200 and LENGTH("Question"."explanation") >= 30')}
  scope :chemistry_mcqs, -> {where(subjectId: 54)}
  scope :botany_mcqs, -> {where(subjectId: 53)}
  scope :zoology_mcqs, -> {where(subjectId: 56)}
  scope :test_questions, -> {where('exists (select * from "TestQuestion", "Test" where "questionId" = "Question"."id" and "Test"."id" = "TestQuestion"."testId" and "Test"."userId" is null and "Test"."id" in (select "testId" from  "ChapterTest" union select "testId" from "CourseTest"))')}
  scope :include_deleted, -> { unscope(:where)  }
  scope :NEET_AIPMT_PMT_Questions, -> {joins("INNER JOIN \"QuestionDetail\" on \"QuestionDetail\".\"questionId\"=\"Question\".\"id\" and \"QuestionDetail\".\"exam\" in ('NEET', 'AIPMT', 'PMT') and \"Question\".\"deleted\"=false")}
  scope :NEET_Test_Questions, -> {where('exists (select * from "TestQuestion", "Test" where "questionId" = "Question"."id" and "Test"."id" = "TestQuestion"."testId" and "Test"."userId" is null and "Test"."exam" in (\'NEET\', \'AIPMT\'))')}
  scope :AIIMS_Questions, -> {joins("INNER JOIN \"QuestionDetail\" on \"QuestionDetail\".\"questionId\"=\"Question\".\"id\" and \"QuestionDetail\".\"exam\" = 'AIIMS' and \"Question\".\"deleted\"=false")}
  #scope :unused_in_high_yield_bio, -> {where('"id" in (select "questionId" from "TestQuestion" where "testId" in (select "testId" from "CourseTest" where "courseId" = 270) and "seqNum" = 0 except select "questionId" from "TestQuestion" where "testId" in (select "testId" from "CourseTest" where "courseId" in (148,452)))')}
  scope :unused_questions, -> {where('not exists (select * from "TestQuestion" where (exists (select * from "CourseTest" where "CourseTest"."testId" = "TestQuestion"."testId") or exists (select * from "ChapterTest" where "ChapterTest"."testId" = "TestQuestion"."testId")) and "TestQuestion"."questionId" = "Question"."id") and not exists (select * from "ChapterQuestion" where "ChapterQuestion"."questionId" = "Question"."id")')}

  scope :abcd_options, -> {where('"type" = \'MCQ-SO\' and "question" ~* \'.*?\s*.*?\(a\).*?\s*.*?\(b\).*?\s*.*?\(c\).*?\s*.*?\(d\).*\' and "question" !~* \'.*?\s*.*?\(?1\)?\.?.*?\s*.*?\(?2\)?\.?.*?\s*.*?\(?3\)?\.?.*?\s*.*?\(?4\)?\.?.*\'')}

  has_many :details, class_name: "QuestionDetail", foreign_key: "questionId"
  has_many :explanations, class_name: "QuestionExplanation", foreign_key: "questionId"
  has_many :translations, class_name: "QuestionTranslation", foreign_key: "questionId"
  has_many :completed_reviewed_translations, -> {where completed: true, reviewed: true}, class_name: "QuestionTranslation", foreign_key: "questionId"
  has_many :hints, class_name: "QuestionHint", foreign_key: "questionId"
  has_one :question_analytic, foreign_key: "id"
  has_many :questionTopics, foreign_key: :questionId, class_name: 'ChapterQuestion'
  has_many :topics, through: :questionTopics
  has_many :questionSubTopics, foreign_key: :questionId, class_name: 'QuestionSubTopic'
  has_many :subTopics, through: :questionSubTopics
  has_many :issues, class_name: "CustomerIssue", foreign_key: "questionId"
  has_many :notes, class_name: "StudentNote", foreign_key: "questionId"
  # belongs_to :test, foreign_key: :testId, optional: true
  has_many :doubts, class_name: "Doubt", foreign_key: "questionId"
  has_many :bookmarks, class_name: "BookmarkQuestion", foreign_key: "questionId"

  has_many :questionTests, foreign_key: :questionId, class_name: 'TestQuestion', dependent: :destroy
  has_many :tests, through: :questionTests, dependent: :destroy

  has_many :systemTests, -> {where userId: nil}, through: :questionTests, dependent: :destroy, source: "test"
  has_many :questionSets, -> {where id: QUESTION_SET_TEST_IDS}, through: :questionTests, dependent: :destroy, source: "test"

  has_many :answers, class_name: "Answer", foreign_key: :questionId

  belongs_to :topic, foreign_key: "topicId", class_name: "Topic", optional: true
  belongs_to :subject, foreign_key: "subjectId", class_name: "Subject", optional: true

  has_many :question_ncert_sentences, class_name: 'QuestionNcertSentence', foreign_key: :questionId, dependent: :destroy
  has_many :question_video_sentences, class_name: 'QuestionVideoSentence', foreign_key: :questionId, dependent: :destroy

  has_and_belongs_to_many :video_sentences, -> { select ['"VideoSentence".*', '"QuestionVideoSentence".id as sentence_id'] }, class_name: :VideoSentence, join_table: :QuestionVideoSentence, foreign_key: :questionId, association_foreign_key: :videoSentenceId
  has_and_belongs_to_many :ncert_sentences, -> { select ['"NcertSentence".*', '"QuestionNcertSentence".id as sentence_id'] }, class_name: :NcertSentence, join_table: :QuestionNcertSentence, foreign_key: :questionId, association_foreign_key: :ncertSentenceId

  def self.distinct_type
    Question.connection.select_all("select distinct \"type\" from \"Question\"")
  end

  def self.distinct_level
    Question.connection.select_all("select distinct \"level\" from \"Question\"")
  end

  def self.ransackable_scopes(_auth_object = nil)
    [:course_subject_id, :similar_questions, :course_name, :subject_ids, :course_id, :course_ids, :test_course_id, :multiple_youtube]
  end
  accepts_nested_attributes_for :details, allow_destroy: true
  accepts_nested_attributes_for :questionSubTopics, allow_destroy: true


  # virtual fields for chapter selection for ncert sentences
  def use_chapter
  end

  def use_chapter=(attr)
  end

  def get_keywords_from_question_ncert_sentences
    topic_stopwords = Question.get_stopwords topic: self.topic
    question_keywords = Question.essential_keywords self.question, stopwords: topic_stopwords

    ncert_sentences_keywords = []
    self.ncert_sentences.pluck(:sentence).each do |ncert_sent|
      ncert_sentences_keywords += Question.essential_keywords ncert_sent,
        stopwords: topic_stopwords
    end

    ncert_sentences_keywords = Question.filter_out_stopwords words: ncert_sentences_keywords.uniq,
      stopwords: topic_stopwords

    keywords = ncert_sentences_keywords + question_keywords
    keywords.uniq
  end

  def self.get_chapterwise_question_csv(topicId)
    # 1. ID
    # 2. Chapter
    # 3. First SubTopic
    # 4. Video Explanation Exists? (Yes / No)
    # 5. Audio Explanation Exists? (Yes / No)
    # 6. No. of Doubts
    # 7. No. of Customer Issues
    # 8. Correct Percentage
    # 9. Question Type: (We would need to configure it as Selected Tests that can be shown in which the question might belong: I have created a similar thing QuestionSet. But, let's create this another list)
    # 9.1) PYQ - Tests in course Id 980
    # 9.2) NCERT Back - test ID 1020201
    # 9.3) Test Series - Course 8 Tests (without past year tests)
    # 10. NCERT Tagging (Yes / No) - NCERT Sentences count > 0 or not

    select_query = <<-SQL
      SELECT DISTINCT ON (question_id) question_id,
        topic_name,
        first_subtopic,
        is_ncert,
        has_ncert_sentences,
        have_video_explanation,
        have_audio_explanation,
        correct_percentage,
        SUM(doubt_count_seq) OVER (PARTITION BY question_id) AS doubt_count,
        SUM(customer_issue_seq) OVER (PARTITION BY question_id) AS customer_issue_count,
        CONCAT(
          CASE
            WHEN question_id IN (SELECT "questionId" FROM "TestQuestion" WHERE "TestQuestion"."testId" IN (#{QUESTION_TYPE_TEST_IDS[:pyq].join ',' }))
            THEN 'PYQ '
            ELSE ''
          END,
          CASE
            WHEN question_id IN (SELECT "questionId" FROM "TestQuestion" WHERE "testId" IN (#{QUESTION_TYPE_TEST_IDS[:ncert_back].join ','}))
            THEN 'NCERT_Back '
            ELSE ''
          END,
          CASE
            WHEN question_id IN (SELECT "questionId" FROM "TestQuestion" WHERE "testId" IN (#{QUESTION_TYPE_TEST_IDS[:test_series].join(',')}))
            THEN 'Test_Series '
            ELSE ''
          END,
          CASE
            WHEN question_id IN (SELECT "questionId" FROM "TestQuestion" WHERE "testId" IN (#{QUESTION_TYPE_TEST_IDS[:already_selected].join(',')}))
            THEN 'Already_Selected'
            ELSE ''
          END
        ) AS question_type
      FROM (
        SELECT
          "Question"."id" AS question_id,
          "Topic"."name" as topic_name,
          "QuestionAnalytics"."correctPercentage" AS correct_percentage,
          "Question"."explanation" LIKE '%youtu%' OR "Question"."explanation" LIKE '%<video%' AS have_video_explanation,
          "Question"."explanation" LIKE '%<audio%' AS have_audio_explanation,
          FIRST_VALUE("SubTopic"."name") OVER (PARTITION BY "Question"."id" ORDER BY "QuestionSubTopic"."createdAt" DESC) AS first_subtopic,
          "Question"."ncert" as "is_ncert",
          COALESCE (MAX("QuestionNcertSentence"."id") OVER (PARTITION BY "QuestionNcertSentence"."id", "QuestionNcertSentence"."questionId"), 0) > 0 AS has_ncert_sentences,

          CASE 
            WHEN ROW_NUMBER() OVER (PARTITION BY "Doubt"."id", "Doubt"."questionId") = 1 AND "Doubt"."id" IS NOT NULL
            THEN 1 
            ELSE 0 
          END AS doubt_count_seq,

          CASE 
            WHEN ROW_NUMBER() OVER (PARTITION BY "CustomerIssue"."id", "CustomerIssue"."questionId") = 1 AND "CustomerIssue"."id" IS NOT NULL
            THEN 1 ELSE 0 
          END AS customer_issue_seq

        FROM "Question"
        LEFT OUTER JOIN "QuestionAnalytics" ON "QuestionAnalytics"."id" = "Question"."id" 
        LEFT OUTER JOIN "Topic" ON "Topic"."id" = "Question"."topicId"
        LEFT OUTER JOIN "Doubt" ON "Doubt"."questionId" = "Question"."id"
        LEFT OUTER JOIN "CustomerIssue" ON "CustomerIssue"."questionId" = "Question"."id"
        LEFT OUTER JOIN "QuestionNcertSentence" on "Question"."id" = "QuestionNcertSentence"."questionId"
        LEFT OUTER JOIN "QuestionSubTopic" ON "QuestionSubTopic"."questionId" = "Question"."id" 
        LEFT OUTER JOIN "SubTopic" ON "SubTopic"."id" = "QuestionSubTopic"."subTopicId" AND "SubTopic"."deleted" = false 

        WHERE 
          "Question"."topicId" = #{ActiveRecord::Base.sanitize_sql(topicId)} AND "Question"."type" = 'MCQ-SO' AND "Question"."deleted" = false
      ) AS U WHERE question_id IS NOT NULL
    SQL

    ActiveRecord::Base.connection.execute(select_query).to_a
  end

  amoeba do
    enable
    include_association :ncert_sentences
    include_association :video_sentences
    include_association :questionSubTopics
  end

end
