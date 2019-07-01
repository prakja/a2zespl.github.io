ActiveAdmin.register Payment do
  config.sort_order = 'createdAt_desc'

  permit_params :amount, :paymentMode, :saleType, :userName, :userEmail, :userPhone, :userState, :userCity, :salesPerson, :revenue, :paytmCut, :gstCut, :pendriveCut ,:netRevenue
  remove_filter :course, :courseInvitation, :versions, :courseInvitations, :paymentCourseInvitations, :paymentForType, :purchasedItemId, :purchasedItemType

  scope :failed_payments

  action_item :fetch_quickbook_payments, only: :index do
    link_to 'Fetch Payments (Quick Book)', Rails.configuration.node_site_url + 'getPaymentsFromQuickBook'
  end

  action_item :update_quickbook_details, only: :show do
    link_to 'Update Payment Details (Quick Book)', Rails.configuration.node_site_url + 'getPaymentsFromQuickBook?quickBookId=' + payment.paymentDesc if payment.paymentMode == 'kotak' and payment.paymentDesc.present?
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
    column :status
    column :verified
    column :courseExpiryAt
    column :createdAt
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
      f.input :saleType, as: :select, :collection => ["inboud","outbound","scholarship","intent"]
      f.input :userName
      f.input :userEmail
      f.input :userPhone
      f.input :userState, as: :select, :collection => ["Andaman and Nicobar Islands","Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chandigarh","Chhattisgarh","Dadra and Nagar Haveli","Daman and Diu","Delhi","Goa","Gujarat","Haryana","Himachal Pradesh","Jammu and Kashmir","Jharkhand","Karnataka","Kerala","Lakshadweep","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram","Nagaland","Odisha","Puducherry","Punjab","Rajasthan","Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal"]
      f.input :userCity
      f.input :salesPerson, as: :select, :collection => AdminUser.sales_team
      f.input :revenue, input_html: { disabled: true }
      f.input :paytmCut, input_html: { disabled: true }
      f.input :gstCut, input_html: { disabled: true }
      f.input :pendriveCut
      f.input :netRevenue, input_html: { disabled: true }
    end
    f.actions
  end

end
