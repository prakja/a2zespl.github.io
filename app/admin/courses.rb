ActiveAdmin.register Course do
  permit_params :name, :description, :package, :fee, :public, :origFee, :discount, :type, :bestSeller, :recommended, :discountedFee, :expiryAt
  remove_filter :payments, :subjects

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Course" do
      f.input :name
      f.input :description
      f.input :package
      f.input :fee
      f.input :public
      f.input :origFee
      f.input :discount
      f.input :type
      f.input :bestSeller
      f.input :recommended
      f.input :discountedFee
      f.input :expiryAt, as: :date_picker
    end
    f.actions
  end
end
