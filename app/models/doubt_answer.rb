class DoubtAnswer < ApplicationRecord
  self.table_name = "DoubtAnswer"
  has_paper_trail
  belongs_to :user, class_name: "User", foreign_key: "userId"
  belongs_to :doubt, class_name: "Doubt", foreign_key: "doubtId"
  
  def imgUrl
    return nil if self.read_attribute(:imgUrl).blank?
    return self.read_attribute(:imgUrl) if self.read_attribute(:imgUrl).include? "http"
    return "https://www.neetprep.com" + self.read_attribute(:imgUrl)
  end

  scope :masterclass_answers, -> { where(:doubtId => Doubt.all_masterclass_paid_student_doubts.ids)}
end
