ActiveAdmin.register CourseInvitation do
  permit_params :course, :displayName, :email, :phone, :role, :payment, :expiryAt, :courseId, :paymentId, :accepted
  remove_filter :payments

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "CourseInvitation" do
      f.input :course, as: :select, :collection => Course.public_courses
      f.input :displayName, label: "Name"
      f.input :email, label: "Email"
      f.input :phone, label: "Phone"
      f.input :role, as: :select, :collection => ["courseStudent", "courseManager", "courseCreator", "courseAdmin"]
      f.input :payments, input_html: { class: "select2" }, :collection => Payment.recent_payments
      f.input :expiryAt, as: :date_picker, label: "Expire Course At"
    end
    f.actions
  end

end
