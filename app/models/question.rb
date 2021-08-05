require 'engtagger'

class Question < ApplicationRecord
  include ActiveModel::Dirty
  extend QuestionKeyword

  before_save :default_values
  after_save :update_question_bank_chapters

  def default_values
    self.options = ["(1)", "(2)", "(3)", "(4)"] if self.options.blank?
    self.level = nil if self.level.blank?
    # find subjectId to be populated
    if (not self.topicId.blank?)
      self.subjectId = SubjectChapter.where(chapterId: self.topicId, subjectId: [53,54,55,56]).limit(1).take()&.subjectId;
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
    self.explanation.match(/<iframe .*youtube\.com\/embed.*<\/iframe>/)
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
  has_many :questionSets, -> {where id: [1020201, 1061903, 1061910, 1061913, 1061915, 1061925, 1061938, 1061940, 1061963, 1061965, 1061969, 1061976, 1061982, 1061988]}, through: :questionTests, dependent: :destroy, source: "test"

  has_many :answers, class_name: "Answer", foreign_key: :questionId

  belongs_to :topic, foreign_key: "topicId", class_name: "Topic", optional: true
  belongs_to :subject, foreign_key: "subjectId", class_name: "Subject", optional: true

  has_many :question_ncert_sentences, class_name: 'QuestionNcertSentence', foreign_key: :questionId, dependent: :destroy
  has_many :question_video_sentences, class_name: 'QuestionVideoSentence', foreign_key: :questionId, dependent: :destroy
  has_and_belongs_to_many :video_sentences, class_name: :VideoSentence, join_table: :QuestionVideoSentence, foreign_key: :questionId, association_foreign_key: :videoSentenceId
  has_and_belongs_to_many :ncert_sentences, class_name: 'NcertSentence', join_table: 'QuestionNcertSentence', foreign_key: :questionId, association_foreign_key: :ncertSentenceId

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

  amoeba do
    enable
    include_association :ncert_sentences
    include_association :video_sentences
    include_association :questionSubTopics
  end

end
