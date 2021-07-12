class Course < ApplicationRecord
  self.table_name = "Course"
  self.inheritance_column = "QWERTY"

  before_create :setCreatedTime, :setUpdatedTime
  before_update :setUpdatedTime
  after_update :courseOfferSync
  has_paper_trail
  before_save :default_values
  def default_values
    self.year = nil if self.year.blank?
    self.image = nil if self.image.blank?
  end

  def setCreatedTime
    self.createdAt = Time.now
  end

  def setUpdatedTime
    self.updatedAt = Time.now
  end

  def self.course_names
    Course.all
      .pluck(:name,:id).map{|course_name, course_id| [course_name, course_id]}
  end

  def courseOfferSync
    course_offer = CourseOffer.where(actualCourseId: self.id).first
    if course_offer
      course_offer.discountedFee = self.discountedFee
      course_offer.fee = self.fee
      course_offer.description = self.feeDesc
      course_offer.save!
    end
  end

  scope :public_courses, -> {where(package: 'neet').order('"id" ASC')}
  has_many :payments, class_name: "Payment", foreign_key: "paymentForId"
  has_many :courseInvitations, class_name: "CourseInvitation", foreign_key: "courseId"
  has_many :courseCourseTests, foreign_key: :courseId, class_name: 'CourseTest'
  has_many :tests, through: :courseCourseTests
  has_many :subjects, class_name: "Subject", foreign_key: "courseId"
  has_many :course_offers, class_name: "CourseOffer", foreign_key: "courseId"

  amoeba do
    enable
    include_association :subjects
  end
end
