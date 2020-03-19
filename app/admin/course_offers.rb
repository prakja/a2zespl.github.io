ActiveAdmin.register CourseOffer do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :description, :courseId, :fee, :discountedFee, :email, :phone, :expiryAt, :durationInDays, :offerExpiryAt, :offerStartedAt, :admin_user_id, :hidden, :position, :createdAt, :updatedAt
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :description, :courseId, :fee, :discountedFee, :email, :phone, :expiryAt, :durationInDays, :offerExpiryAt, :offerStartedAt, :admin_user_id, :hidden, :position, :createdAt, :updatedAt]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  remove_filter :admin_user, :course
  permit_params :title, :text, :courseId, :fee, :email, :phone, :durationInDays, :offerExpiryAt, :offerStartedAt, :position, :hidden, :admin_user_id, :course

  form do |f|
    f.semantic_errors *f.object.errors.keys
    # f.object.admin_user_id = current_admin_user.id
    f.inputs "Course Offer" do
      f.input :title
      f.input :description
      f.input :course, input_html: { class: "select2" }
      f.input :fee
      f.input :email
      f.input :phone
      f.input :durationInDays
      f.input :offerExpiryAt, as: :datetime_picker
      f.input :offerStartedAt, as: :datetime_picker
      f.input :position
      f.input :hidden
      f.input :admin_user_id, :input_html => { :value => current_admin_user.id }
    end
    f.actions
  end
  
end
