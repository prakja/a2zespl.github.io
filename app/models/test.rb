class Test < ApplicationRecord
  before_save :default_values
  #default_scope {where(userId: nil)}
  scope :dynamic_tests, -> {unscope(:where).where.not(userId: nil)}
  def default_values
    self.ownerType = nil if self.ownerId.blank?
    self.exam = nil if self.exam.blank?
  end

  after_commit :after_update_test, if: Proc.new { |model| model.previous_changes[:sections]}, on: [:update]
  before_create :setSections
  before_update :setSections

  def setSections
    if self.pdfURL.blank?
      self.pdfURL = nil
    else
      self.pdfURL = self.pdfURL
    end

    if self.sections.blank?
      self.sections = nil
    else
      self.sections = JSON.parse(self.sections)
    end
  end

  def test_attempt(user_id)
    self.test_attempts.where(userId: user_id, completed: true).order(createdAt: :desc).first
  end

  def update_section_question_subject
    if not self.sections.blank?
      # update subjectId in question if not present
      self.sections.each_with_index do |section, index|
        subjectId = nil
        if section[0] == "Physics"
          subjectId = 55
        elsif section[0] == "Chemistry"
          subjectId = 54
        elsif section[0] == "Biology"
          # TODO: how to get Botany and Zoology differentiated?? for now, Botany is default
          subjectId = 53
        end
        limit = self.sections[index + 1].nil? ? (self.numQuestions - section[1] + 1) : self.sections[index + 1][1] - section[1]
        offset = section[1] - 1
        questions = self.questions.order(seqNum: :asc, id: :asc).select(:id, :subjectId, :topicId).limit(limit).offset(offset);
        question_ids = []
        questions.each do |question|
          if question.subjectId.blank? and question.topicId.blank?
            question_ids << question.id
          end
        end
        Question.where(id: question_ids).update_all(subjectId: subjectId)
      end
    end
  end

  def after_update_test
    if self.sections.blank?
      return
    end

    self.update_section_question_subject
    HTTParty.post(
      Rails.configuration.node_site_url + "api/v1/webhook/updateTestAttempts",
       body: {
         id: self.id
    })
  end

  def questions_with_number
    questions = ""
    self.questions.order(seqNum: :asc, id: :asc).select(:id, :seqNum).each_with_index {|question, index|
       questions = questions + (index + 1).to_s + ' > ' + '<a target="_blank" href="/admin/questions/' + question.id.to_s + '">' + question.id.to_s + '</a>' + ' ( ' + question.seqNum.to_s + ' )' + '<br/>'
    }
    return questions
  end

  has_paper_trail
  self.table_name = "Test"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
  # belongs_to :topic, foreign_type: 'ownerType', foreign_key: 'ownerId', optional: true
  has_many :testCourseTests, foreign_key: :testId, class_name: 'CourseTest'
  has_many :courses, through: :testCourseTests

  has_many :testChapterTests, foreign_key: :testId, class_name: 'ChapterTest'
  has_many :topics, through: :testChapterTests
  # has_many :questions, class_name: "Question", foreign_key: "testId"
  has_many :test_leader_boards, class_name: "TestLeaderBoard", foreign_key: "testId"

  has_many :testQuestions, -> {joins(:question).order('"TestQuestion"."seqNum" ASC, "Question"."id" ASC')} , foreign_key: :testId, class_name: 'TestQuestion', dependent: :destroy
  has_many :questions, -> { order(seqNum: :asc, id: :asc) }, through: :testQuestions, dependent: :destroy
  has_many :question_ids, -> { order(seqNum: :asc, id: :asc).select(:id) }, through: :testQuestions

  has_many :test_attempts, class_name: "TestAttempt", foreign_key: "testId"
  has_many :target, class_name: "Target", foreign_key: "testId"

  scope :course_name, ->(course_id) {
    joins(:testCourseTests => :course).where(testCourseTests: {Course: {id: course_id}})
  }

  scope :neet_course, -> {course_name(8)}
  scope :system_tests, -> {where(userId: nil)}
  scope :test_series_2018, -> {course_name(128)}
  scope :test_series_2019, -> {course_name(148)}
  scope :test_series_2020, -> {course_name(452)}

  scope :botany, -> {joins(:topics => :subject).where(topics: {Subject: {id:  [53, 478, 495]}})}
  scope :chemistry, -> {joins(:topics => :subject).where(topics: {Subject: {id:  [54, 477, 494]}})}
  scope :physics, -> {joins(:topics => :subject).where(topics: {Subject: {id:  [55, 476, 493]}})}
  scope :zoology, -> {joins(:topics => :subject).where(topics: {Subject: {id:  [56, 479, 496]}})}

  def get_remaining_ncert_question(subtopicId:, easy_medium_level:, limit:, ignore: [])
    qs = Question.joins(:questionSubTopics)
      .left_outer_joins(:question_analytic)
      .joins('LEFT OUTER JOIN "ReplaceDuplicateQuestion" ON "ReplaceDuplicateQuestion"."removeQuestionId" = "Question"."id"')
      .joins('LEFT OUTER JOIN "TestQuestion" ON "TestQuestion"."questionId" = "Question"."id" and "TestQuestion"."testId" = ' + self.id.to_s)
      .where(QuestionSubTopic: {:subTopicId => subtopicId})
      .where('"TestQuestion"."id" is null')
      .where('"QuestionAnalytics"."correctPercentage" >= 50')

    qs = qs.where(Question: {:ncert => true, type: 'MCQ-SO'})

    unless ignore.empty?
      qs = qs.where('"QuestionSubTopic"."questionId" NOT IN (?)', ignore)
    end

    if easy_medium_level
      qs = qs.where('"QuestionAnalytics"."correctPercentage" >= 50')
    end

    Question.where(id: qs.pluck('DISTINCT(COALESCE("keepQuestionId", "Question"."id")) as "qId"')).order('random()').limit(limit).pluck(:id)
  end

  def question_selection(
    chapterId:, subtopic_id_wise_question_count:, 
    preference_previous_year:false, preference_video_audio_solution:false,
    easy_medium_level: false
  )

    # remove entries where limit is 0
    subtopic_id_wise_question_count = subtopic_id_wise_question_count.delete_if { |id, limit| limit.to_i == 0}

    # get the subject for the given chapterId
    chapter = Topic.find chapterId

    if [53, 56].include? chapter.subjectId 
      subject = 'bio'
    end 

    subject = 'phy' if chapter.subjectId == 55
    subject = 'chem' if chapter.subjectId == 54

    test_question_ids = []

    # get questions per subtopics
    subtopic_id_wise_question_count.each do |subtopicId, limit|
      subtopicId, limit = subtopicId.to_i, limit.to_i

      # base query
      qs = Question.joins(:questionSubTopics, :tests)
        .left_outer_joins(:question_analytic)
        .joins('LEFT OUTER JOIN "ReplaceDuplicateQuestion" ON "ReplaceDuplicateQuestion"."removeQuestionId" = "Question"."id"')
        .joins('LEFT OUTER JOIN "TestQuestion" ON "TestQuestion"."questionId" = "Question"."id" and "TestQuestion"."testId" = ' + self.id.to_s)
        .where(QuestionSubTopic: {:subTopicId => subtopicId})
        .where('"TestQuestion"."id" is null')

      qs = qs.where(Question: {:ncert => true, type: 'MCQ-SO'})

      if preference_previous_year
        qs = qs.where('"Test"."exam" IN (?)', ['NEET', 'AIPMT'])
      end

      if preference_video_audio_solution
        like_q = (subject == 'bio') ? '%<audio%>%' : '%<iframe%>'
        qs = qs.where('"Question"."explanation" like ?', like_q)
      end

      if easy_medium_level
        qs = qs.where('"QuestionAnalytics"."correctPercentage" >= 50')
      end

      questionIds = Question.where(id: qs.pluck('DISTINCT(COALESCE("keepQuestionId", "Question"."id")) as "qId"')).order('random()').limit(limit).pluck(:id)

      remaining = limit - questionIds.length

      # get extra questions if some pending
      if remaining > 0
        questionIds += self.get_remaining_ncert_question subtopicId: subtopicId, 
          easy_medium_level: easy_medium_level, limit: remaining, ignore: questionIds
      end

      test_question_ids += questionIds
    end

    return test_question_ids
  end

  def add_questions_of_same_chapter(questionIdList:, chapterId:)
    chapter = Topic.find chapterId.to_i

    if [53, 56].include? chapter.subjectId 
      # assume seqNum >= 10000 
      seqNum = 10000 + self.questions.count
    elsif chapter.subjectId == 54
      # assume seqNum >= 20000 
      seqNum = 20000 + self.questions.count
    elsif chapter.subjectId == 55
      # assume seqNum >= 30000
      seqNum = 30000 + self.questions.count
    else
      seqNum = 0
    end

    test_questions = []

    questionIdList.each do |questionId|
      seqNum += 1
      test_questions << TestQuestion.new(:testId => self.id, :questionId => questionId, :seqNum => seqNum)
    end

    TestQuestion.import test_questions
  end
end
