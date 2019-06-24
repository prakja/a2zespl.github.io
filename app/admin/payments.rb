ActiveAdmin.register Payment do
  config.sort_order = 'createdAt_desc'

  permit_params :amount, :paymentMode
  remove_filter :course, :courseInvitation, :versions, :courseInvitations, :paymentCourseInvitations

  scope :failed_payments

  action_item :fetch_quickbook_payments, only: :index do
    link_to 'Fetch Payments (Quick Book)', Rails.configuration.node_site_url + 'getPaymentsFromQuickBook'
  end

  action_item :update_quickbook_details, only: :show do
    link_to 'Update Payment Details (Quick Book)', Rails.configuration.node_site_url + 'getPaymentsFromQuickBook?quickBookId=' + payment.paymentDesc if payment.paymentMode == 'kotak' and payment.paymentDesc.present?
  end

  show do |f|
    attributes_table do
      row :course
      row :status
      row :amount
      row :userName
      row :userEmail
      row :userPhone
      row :paymentMode
      row :paymentDesc
      row :verified
      row :courseExpiryAt
    end
  end

  index do
    id_column
    column :course
    column (:amount) { |payment| raw(payment.amount)  }
    column (:userName) { |payment| raw(payment.userName)  }
    column (:userEmail) { |payment| raw(payment.userEmail)  }
    column (:userPhone) { |payment| raw(payment.userPhone)  }
    column (:paymentMode) { |payment| raw(payment.paymentMode)  }
    column (:paymentDesc) { |payment| raw(payment.paymentDesc)  }
    column (:verified) { |payment| raw(payment.verified)  }
    column (:courseExpiryAt) { |payment| raw(payment.courseExpiryAt)  }
    column ("History") {|payment| raw('<a target="_blank" href="/admin/payments/' + (payment.id).to_s + '/history">View History</a>')}
    actions
  end

  member_action :history do
    @payment = Payment.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Payment', item_id: @payment.id)
    render "layouts/history"
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Payment" do
      f.input :amount, label: "Payment amount"
      f.input :paymentMode, as: :select, :collection => ["cash"]
    end
    f.actions
  end

end
