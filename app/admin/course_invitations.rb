ActiveAdmin.register CourseInvitation do
  permit_params :course, :displayName, :email, :phone, :role, :payments, :expiryAt, :courseId, :accepted, payment_ids: []
  remove_filter :payments, :versions, :courseInvitationPayments
  scope :invitations_without_payment_last_7_days

  member_action :history do
    @courseinvitation = CourseInvitation.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'CourseInvitation', item_id: @courseinvitation.id)
    render "layouts/history"
  end

  csv do
    column (:course) { |courseInvitation| raw(courseInvitation.course.name)  }
    column (:displayName) { |courseInvitation| raw(courseInvitation.displayName)  }
    column (:email) { |courseInvitation| raw(courseInvitation.email)  }
    column (:phone) { |courseInvitation| raw(courseInvitation.phone)  }
    column "Amount" do |courseInvitation|
     courseInvitation.payments.map { |payment| payment.amount.to_int }.compact
    end
    column :expiryAt
    column :createdAt
  end

  index do
    id_column
    column :course
    column (:displayName) { |courseInvitation| raw(courseInvitation.displayName)  }
    column (:email) { |courseInvitation| raw(courseInvitation.email)  }
    column (:phone) { |courseInvitation| raw(courseInvitation.phone)  }
    column (:role) { |courseInvitation| raw(courseInvitation.role)  }
    column :payments
    column "Amount" do |courseInvitation|
     courseInvitation.payments.map { |payment| payment.amount }.compact
    end
    column :expiryAt
    column :createdAt
    column ("History") {|courseInvitation| raw('<a target="_blank" href="/admin/course_invitations/' + (courseInvitation.id).to_s + '/history">View History</a>')}
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "CourseInvitation" do
      f.input :course, as: :select, :collection => Course.public_courses
      f.input :displayName, label: "Name"
      f.input :email, label: "Email"
      f.input :phone, label: "Phone"
      f.input :role, as: :select, :collection => ["courseStudent", "courseManager", "courseCreator", "courseAdmin"]
      f.input :payments, include_hidden: false, multiple: true, input_html: { class: "select2" }, :collection => Payment.recent_payments_with_props
      f.input :expiryAt, as: :date_picker, label: "Expire Course At"
    end
    f.actions
  end

end
