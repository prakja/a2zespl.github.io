ActiveAdmin.register Payment do
permit_params :paymentForType, :amount, :userId, :userName, :userEmail, :userPhone, :paymentMode, :paymentDesc, :courseExpiryAt, :paymentForId, :course, :verified
remove_filter :course

action_item :fetch_quickbook_payments, only: :index do
  link_to 'Fetch Payments (Quick Book)', 'http://localhost:3000/getPaymentsFromQuickBook'
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
    f.input :paymentDesc, as: :string , label: "Payment Description", hint: "Enter paytm order Id Or Kotak SalesReciept Id Or cash payment time"
    if f.object.paymentMode == 'cash' || f.object.new_record?
      f.input :verified, lable: "Payment Verified", hint: "Mark checked only if payment is verified"
    end
    f.input :courseExpiryAt, as: :date_picker, label: "Expire Course At"
  end
  f.actions
end

end
