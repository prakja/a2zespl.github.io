ActiveAdmin.register CourseInvitation do
  permit_params :course, :displayName, :email, :phone, :role, :payment, :expiryAt, :courseId, :paymentId, :accepted

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "CourseInvitation" do
      f.input :course, as: :select, :collection => Course.public_courses
      f.input :displayName, label: "Name"
      f.input :email, label: "Email"
      f.input :phone, label: "Phone"
      f.input :role, as: :select, :collection => ["courseStudent", "courseManager", "courseCreator", "courseAdmin"]
      f.input :payment, input_html: { class: "select2" }, :collection => Payment.pluck(:id).map{|payment_id| [payment_id]}
      f.input :expiryAt, as: :date_picker, label: "Expire Course At"
    end
    f.actions
  end

end
