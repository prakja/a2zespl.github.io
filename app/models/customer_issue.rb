class CustomerIssue < ApplicationRecord
  self.table_name = "CustomerIssue"

  belongs_to :topic, foreign_key: :topicId, optional: true
  belongs_to :question, foreign_key: :questionId, optional: true
  belongs_to :video, foreign_key: :videoId, optional: true
  belongs_to :test, foreign_key: :testId, optional: true
  belongs_to :customer_issue_type, foreign_key: :typeId
  belongs_to :user, foreign_key: :userId

  scope :subject_name, ->(subject_id) {
    joins(:topic => :subjects).where(topic: {Subject: {id: subject_id}})
  }

  scope :test_subject, ->(subject_id) {
    joins(:question).where(Question: {subjectId: subject_id})
  }

  scope :test_subject_topic_nil, ->(subject_id) {
    test_subject(subject_id).where(Question: {topicId: nil})
  }

  scope :non_resolved, ->() {
    where(resolved: false)
  }

  scope :question_issue, -> () {
    where.not(questionId: nil)
  }

  scope :video_issue, -> () {
    where.not(videoId: nil)
  }

  scope :test_issue, -> () {
    where.not(testId: nil)
  }

  scope :full_tests, -> () {
    joins(:test).where(Test: {numQuestions: 180}).non_resolved()
  }

  scope :botany_question_issues, -> {subject_name([53, 478, 132, 495, 390, 222]).non_resolved().question_issue.distinct}
  scope :chemistry_question_issues, -> {subject_name([54, 477, 129, 494, 391, 229, 169]).non_resolved().question_issue.distinct}
  scope :physics_question_issues, -> {subject_name([55, 476, 126, 493, 392, 232, 170]).non_resolved().question_issue.distinct}
  scope :zoology_question_issues, -> {subject_name([56, 479, 135, 496, 393, 234]).non_resolved().question_issue.distinct}

  scope :physics_test_issues, -> {test_subject(55).non_resolved().question_issue.test_issue.distinct}
  scope :chemistry_test_issues, -> {test_subject(54).non_resolved().question_issue.test_issue.distinct}
  scope :biology_test_issues, -> {test_subject_topic_nil(53).non_resolved().question_issue.test_issue.distinct}
  scope :zoology_test_issues, -> {test_subject(56).non_resolved().question_issue.test_issue.distinct}
  scope :botany_test_issues, -> {test_subject(53).non_resolved().question_issue.test_issue.distinct}

  scope :botany_video_issues, -> {subject_name([53, 478, 480, 132, 495, 390, 222]).non_resolved().video_issue.distinct}
  scope :chemistry_video_issues, -> {subject_name([54, 477, 481, 129, 494, 391, 229, 169]).non_resolved().video_issue.distinct}
  scope :physics_video_issues, -> {subject_name([55, 476, 482, 126, 493, 392, 232, 170]).non_resolved().video_issue.distinct}
  scope :zoology_video_issues, -> {subject_name([56, 479, 483, 135, 496, 393, 234]).non_resolved().video_issue.distinct}

  scope :masterclass, -> {subject_name([627..630]).non_resolved().question_issue.distinct}
  scope :masterclass_tests, -> {subject_name([627..630]).non_resolved().question_issue.test_issue.distinct}

  def self.ransackable_scopes(_auth_object = nil)
    [:subject_name]
  end
end
