ActiveAdmin.register Doubt do
  permit_params :content, :deleted, :teacherReply, :imgUrl
  scope :botany_paid_student_doubts
  scope :chemistry_paid_student_doubts
  scope :physics_paid_student_doubts
  scope :zoology_paid_student_doubts
end
