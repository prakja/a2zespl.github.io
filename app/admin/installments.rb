ActiveAdmin.register Installment do
  permit_params :paymentId, :secondInstallmentDate, :secondInstallmentAmount, :finalInstallmentDate, :finalInstallmentAmount, :payment
  remove_filter :versions, :payment

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Installment" do
      f.input :payment, label: "Payment Id", input_html: { class: "select2" }, :collection => Payment.recent_payments
      f.input :secondInstallmentDate, as: :date_picker, label: "Second Installment Date"
      f.input :secondInstallmentAmount, label: "Second Installment Amount"
      f.input :finalInstallmentDate, as: :date_picker, label: "Final Installment Date"
      f.input :finalInstallmentAmount, label: "Final Installment Amount"
    end
    f.actions
  end
end
