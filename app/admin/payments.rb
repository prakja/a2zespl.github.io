ActiveAdmin.register Payment do
  config.sort_order = 'createdAt_desc'

  permit_params :amount, :paymentMode, :saleType, :userName, :userEmail, :userPhone, :userState, :userCity, :salesPerson, :revenue, :paytmCut, :gstCut, :pendriveCut ,:netRevenue, :course, :paymentForId, :createdAt
  remove_filter :course, :courseInvitation, :versions, :courseInvitations, :paymentCourseInvitations, :paymentForType, :purchasedItemId, :purchasedItemType, :salesPerson, :revenue, :paytmCut, :gstCut, :pendriveCut, :netRevenue, :user
  preserve_default_filters!
  filter :userId_eq, as: :number, label: "User ID"

  #scope :kotak_payments, show_count: false
  scope :successful_payments, show_count: false, default: true
  scope :direct_payments_master_class, show_count: false
  scope :direct_payments_test_series, show_count: false
  scope :failed_payments, show_count: false
  scope :failed_payments_10k, show_count: false
  scope :failed_payments_5k, show_count: false
  scope :paytm_payments, show_count: false
  scope :all, show_count: false
  #scope :cash_payments, show_count: false

  action_item :fetch_quickbook_payments, only: :index do
    link_to 'Fetch Payments (Quick Book)', Rails.configuration.node_site_url + 'getPaymentsFromQuickBook'
  end

  action_item :update_quickbook_details, only: :show do
    link_to 'Update Payment Details (Quick Book)', Rails.configuration.node_site_url + 'getPaymentsFromQuickBook?quickBookId=' + payment.paymentDesc if payment.paymentMode == 'kotak' and payment.paymentDesc.present?
  end

  csv do
    column ("Date Of Sale") {|payment| payment.createdAt}
    column :saleType
    column :userName
    column :userEmail
    column :userPhone
    column :userState
    column :userCity
    column :salesPerson
    column :paymentMode
    column ("Order Id") {|payment| raw(payment.paymentDesc)}
    column :revenue
    column :paytmCut
    column :gstCut
    column :pendriveCut
    column :netRevenue
    column ("Second Installment Date") { |payment|
      if payment.installment
        payment.installment.secondInstallmentDate
      end
    }
    column ("Second Installment Amount") { |payment|
      if payment.installment
        payment.installment.secondInstallmentAmount
      end
    }
    column ("Final Installment Date") { |payment|
      if payment.installment
        payment.installment.finalInstallmentDate
      end
    }
    column ("Final Installment Amount") { |payment|
      if payment.installment
        payment.installment.finalInstallmentAmount
      end
    }
  end

  controller do
    def scoped_collection
      super.includes :course, :installment, :user
    end
  end

  index do
    id_column
    column :createdAt
    column :course
    column (:amount) { |payment| raw(payment.amount)  }
    column (:status) { |payment| raw(payment.status)  }
    column (:userName) { |payment| raw(payment.userName)}
    column (:userEmail) { |payment| raw(payment.userEmail || payment.user.email)  }
    column (:userPhone) { |payment| raw(payment.userPhone || payment.user.phone)  }
    column (:paymentMode) { |payment| raw(payment.paymentMode)  }
    column (:paymentDesc) { |payment| raw(payment.paymentDesc)  }
    column :courseExpiryAt
    if current_admin_user.role == 'admin' or current_admin_user.role == 'accounts'
      column :userState
      column :userCity
      column :salesPerson
      column :revenue
      column :paytmCut
      column :gstCut
      column :pendriveCut
      column :netRevenue
      column :installment
      column ("Get Invoice") { |payment|
        if payment.course && payment.userName && payment.amount && payment.userState && payment.userCity && payment.installment
          raw('<a target="_blank" href="'+ Rails.configuration.node_site_url + 'getInvoice?id=' + (payment.id).to_s + '&name=' + (payment.userName).to_s + '&course=' + (payment.course.name).to_s + '&qty=1&amount=' + (payment.amount).to_s + + '&state=' + (payment.userState).to_s + '&city=' + (payment.userCity).to_s + '&invoiceDate=' + (payment.createdAt).to_s + '&secondInstallmentDate=' + (payment.installment.secondInstallmentDate).to_s + '&secondInstallmentAmount=' + (payment.installment.secondInstallmentAmount).to_s + '&finalInstallmentDate=' + (payment.installment.finalInstallmentDate).to_s + '&finalInstallmentAmount=' + (payment.installment.finalInstallmentAmount).to_s + '">Get Invoice</a>')
        else
          raw('<a target="_blank" href="'+ Rails.configuration.node_site_url + 'getInvoice?id=' + (payment.id).to_s + '&name=' + (payment.userName || payment&.user&.user_profile&.displayName).to_s + '&course=' + (payment&.course&.name).to_s + '&qty=1&amount=' + (payment.amount).to_s + + '&state=' + (payment.userState).to_s + '&city=' + (payment.userCity).to_s + '&invoiceDate=' + (payment.createdAt).to_s + '">Get Invoice</a>')
        end
      }
    end
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
      if current_admin_user.role == 'admin' or current_admin_user.role == 'accounts'
        f.input :paymentMode, as: :select, :collection => ["paytm","kotak","cash","paytm wallet"]
      else
        f.input :paymentMode, as: :select, :collection => ["cash","paytm wallet"]
      end
      if current_admin_user.role == 'admin' or current_admin_user.role == 'accounts'
        f.input :course, as: :select, :collection => Course.public_courses
        f.input :saleType, as: :select, :collection => ["inboud","outbound","scholarship","intent"]
        f.input :userName
        f.input :userEmail
        f.input :userPhone
        f.input :userState, input_html: { class: "select2" }, :collection => ["Andaman and Nicobar Islands","Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chandigarh","Chhattisgarh","Dadra and Nagar Haveli","Daman and Diu","Delhi","Goa","Gujarat","Haryana","Himachal Pradesh","Jammu and Kashmir","Jharkhand","Karnataka","Kerala","Lakshadweep","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram","Nagaland","Odisha","Puducherry","Punjab","Rajasthan","Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal"]
        f.input :userCity
        f.input :salesPerson, as: :tags, :collection => AdminUser.sales_team
        f.input :revenue, input_html: { disabled: true }
        f.input :paytmCut, input_html: { disabled: true }
        f.input :gstCut, input_html: { disabled: true }
        f.input :pendriveCut
        f.input :netRevenue, input_html: { disabled: true }
        f.input :createdAt, as: :date_picker
      end
    end
    f.actions
  end

end
