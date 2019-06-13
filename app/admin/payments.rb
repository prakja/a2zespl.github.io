ActiveAdmin.register Payment do
permit_params :paymentForType, :amount, :userId, :userName, :userEmail, :userPhone, :paymentMode, :paymentDesc, :courseExpiryAt, :paymentForId, :course, :verified
remove_filter :course, :courseInvitation, :versions, :courseInvitations

scope :failed_payments

action_item :fetch_quickbook_payments, only: :index do
  link_to 'Fetch Payments (Quick Book)', Rails.configuration.node_site_url + 'getPaymentsFromQuickBook'
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
    f.input :course, as: :select, :collection => Course.public_courses
    f.input :amount, label: "Payment amount"
    f.input :userName, label: "Student Name"
    f.input :userEmail, label: "Student Email"
    f.input :userPhone, label: "Student Phone"
    f.input :paymentMode, as: :select, :collection => ["kotak", "paytm", "cash"]
    f.input :paymentDesc, as: :string, label: "Payment Description", hint: "Enter paytm order Id Or Kotak SalesReciept Id Or cash payment time", input_html: {disabled: true, value: f.object.paymentDesc }
    if f.object.paymentMode == 'cash' || f.object.new_record?
      f.input :verified, lable: "Payment Verified", hint: "Mark checked only if payment is verified"
    end
    f.input :courseExpiryAt, as: :date_picker, label: "Expire Course At"
  end
  f.actions
end

end
