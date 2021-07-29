ActiveAdmin.register CourseOffer do
  duplicatable
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
  permit_params :title, :text, :courseId, :fee, :discountedFee, :email, :phone, :durationInDays, :offerExpiryAt, :offerStartedAt, :position, :hidden, :admin_user_id, :course, :expiryAt, :description, :actualCourseId

  index do
    id_column
    column :title
    column :description
    column :course
    column :fee
    column :discountedFee
    column :email
    column :phone
    column :expiryAt
    column :offerStartedAt
    column :offerExpiryAt
    column :admin_user
    actions
  end

  form do |f|
    # f.object.admin_user_id = current_admin_user.id
    f.inputs "Course Offer" do
      f.input :title
      f.input :description
      f.input :course, input_html: { class: "select2" }, hint: "Select the course that you are trying to sell to the user"
      f.input :fee, hint: "Real Course price"
      f.input :discountedFee, hint: "The price user will pay"
      f.input :email, hint: "User email address"
      f.input :phone, hint: "User phone number"
      if current_admin_user.role == 'admin' 
        f.input :durationInDays, hint: "Duration for which you wanna give the course access for"
        f.input :position, hint: "This is for the web to manage position"
      end
      f.input :expiryAt, as: :date_picker, label: "Course Expiry At", hint: "Date on which the coures should expire"
      f.input :offerStartedAt, as: :date_picker, label: "Offer Start At", hint: "Date after which the user can avail this offer"
      f.input :offerExpiryAt, as: :date_picker, label: "Offer Expiry At", hint: "Date until which the user can avail this offer"
      f.input :actualCourseId
      f.input :hidden
      f.input :admin_user_id, as: :hidden, :input_html => { :value => current_admin_user.id } if f.object.admin_user_id.blank?
      f.input :admin_user_id, as: :hidden if not f.object.admin_user_id.blank?
    end
    f.actions
  end
  
end
