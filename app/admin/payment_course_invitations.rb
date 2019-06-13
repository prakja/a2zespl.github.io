ActiveAdmin.register PaymentCourseInvitation do
  permit_params :courseInvitation, :payment, :courseInvitationId, :paymentId
  remove_filter :courseInvitation, :payment, :createdAt, :updatedAt

  index do
    id_column
    column :courseInvitation
    column :payment
    column (:createdAt) { |paymentCourseInvitation| raw(paymentCourseInvitation.createdAt)  }
    column (:updatedAt) { |paymentCourseInvitation| raw(paymentCourseInvitation.updatedAt)  }
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "CourseInvitation" do
      f.input :courseInvitation, as: :select, :collection => CourseInvitation.recent_course_invitations
      f.input :payment, as: :select, :collection => Payment.recent_payments
    end
    f.actions
  end
end
