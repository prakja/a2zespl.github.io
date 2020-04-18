class CustomerIssue < ApplicationRecord
 self.table_name = "CustomerIssue"

 belongs_to :topic, foreign_key: :topicId, optional: true
 belongs_to :question, foreign_key: :questionId, optional: true
 belongs_to :video, foreign_key: :videoId, optional: true
 belongs_to :test, foreign_key: :testId, optional: true
 belongs_to :user, foreign_key: :userId

 scope :subject_name, ->(subject_id) {
  joins(:topic => :subjects).where(topic: {Subject: {id: subject_id}})
 }

 scope :non_resolved, ->() {
  where(resolved: false)
 }

 scope :botany_issues, -> {subject_name([53, 478, 132, 495, 390, 222]).non_resolved()}
 scope :chemistry_issues, -> {subject_name([54, 477, 129, 494, 391, 229, 169]).non_resolved()}
 scope :physics_issues, -> {subject_name([55, 476, 126, 493, 392, 232, 170]).non_resolved()}
 scope :zoology_issues, -> {subject_name([56, 479, 135, 496, 393, 234]).non_resolved()}

 def self.ransackable_scopes(_auth_object = nil)
  [:subject_name]
 end
end
