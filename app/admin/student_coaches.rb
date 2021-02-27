ActiveAdmin.register StudentCoach do
  permit_params :studentId, :coachId, :role
  remove_filter :studentId, :coachId, :student, :admin_user

  filter :studentId_eq, as: :number, label: "Student ID"
  filter :student_email, as: :string, label: "Student Email"
  filter :student_phone, as: :string, label: "Student Phone"
  filter :coachId_eq, as: :searchable_select, label: "Coach", :collection => AdminUser.distinct_email_id

  active_admin_import validate: true,
    batch_size: 1,
    timestamps: true,
    headers_rewrites: { 'coachId': :coachId, 'studentId': :studentId, 'role': :role, 'created_at': :created_at, 'updated_at': :updated_at },
    before_batch_import: ->(importer) {
      # add created at and upated at
      studentEmail = nil
      importer.csv_lines.each do |line|
        time = Time.now
        studentEmail = line[-1]
        coachId = line[0]
        check_existing = StudentCoach.joins(:student).where(User: {email: studentEmail}).first
        if check_existing.nil?
          student = User.where(email: studentEmail).first
          if not student.nil?
            line.pop
            line.insert(-1, student.id)
            line.insert(-1, "PrimaryCoach")
            line.insert(-1, time)
            line.insert(-1, time)
          else
            return
          end
        else
          return
        end
      end
    },
    after_batch_import:  ->(importer){
      p "after_import"
    },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: coachId, student_email.
        Remove the header from the CSV before uploading.",
        csv_headers: ['coachId', 'studentId', 'role', 'created_at', 'updated_at']
    )

  index do
    id_column
    column "Student" do |student_coach|
      student_coach.student
    end
    column "Student Email" do |student_coach|
      student_coach.student.email
    end
    column "Coach" do |student_coach|
      student_coach.admin_user.email
    end
    #column (:role) { |student_coach| raw(student_coach.role) }
    column :created_at
    #column :updated_at
    if current_admin_user.admin?
      actions
    else
      column "Links" do |student_coach|
        raw '<a href="/coach-dashboard-summary?studentId=' + student_coach.studentId.to_s + '" target="_blank">View Summary</a> &amp; <a href="/coach-dashboard?studentId=' + student_coach.studentId.to_s + '" target="_blank">View Overview</a>'
      end
    end
  end

  controller do
    def scoped_collection
      super.preload(student: :user_profile)
    end
  end

  scope "My Students", show_count: false, default: true do |student_coach|
    StudentCoach.my_students(current_admin_user.id.to_s)
  end
  scope :all, show_count: false, if: -> {current_admin_user.admin?}

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
