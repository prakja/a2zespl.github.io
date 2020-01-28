ActiveAdmin.register StudentCoach do
  permit_params :studentId, :coachId, :role
  remove_filter :studentId, :coachId, :user, :admin_user

  filter :studentId_eq, as: :number, label: "Student ID"
  filter :user_email, as: :string, label: "Student Email"
  filter :user_phone, as: :string, label: "Student Phone"
  filter :coachId_eq, as: :searchable_select, label: "Coach", :collection => AdminUser.distinct_email_id

  index do
    id_column
    column "Student" do |student_coach|
      student_coach.user
    end
    column "Coach" do |student_coach|
      student_coach.admin_user.email
    end
    column (:role) { |student_coach| raw(student_coach.role) }
    column :created_at
    column :updated_at
    actions
  end

  scope "My Students" do |student_coach|
    StudentCoach.my_students(current_admin_user.id.to_s)
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "StudentCoach" do
      f.input :studentId, label: "Student Id"
      f.input :admin_user, input_html: { class: "select2" }, :collection => AdminUser.distinct_email_id, label: "Coach"
      f.input :role, as: :select, :collection => ["PrimaryCoach", "PhysicsCoach", "ChemistryCoach", "BiologyCoach"]
    end
    f.actions
  end
end
