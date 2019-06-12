ActiveAdmin.register CourseInvitation do
  permit_params :course, :displayName, :email, :phone, :role, :payments, :expiryAt, :courseId, :accepted, payment_ids: []
  remove_filter :payments

  show do |f|
    attributes_table do
      row :id
      row :course
      row :displayName
      row :email
      row :phone
      row :role
      row :payments
      row :expiryAt
    end
  end

  index do
    id_column
    column :course
    column (:displayName) { |courseInvitation| raw(courseInvitation.displayName)  }
    column (:email) { |courseInvitation| raw(courseInvitation.email)  }
    column (:phone) { |courseInvitation| raw(courseInvitation.phone)  }
    column (:role) { |courseInvitation| raw(courseInvitation.role)  }
    column :payments
    column (:expiryAt) { |courseInvitation| raw(courseInvitation.expiryAt)  }
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
