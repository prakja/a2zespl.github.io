ActiveAdmin.register Course do
  permit_params :name, :year, :image, :description, :package, :fee, :public, :hasVideo, :allowCallback, :origFee, :discount, :type, :bestSeller, :recommended, :discountedFee, :expiryAt
  remove_filter :payments, :subjects, :versions, :courseInvitations, :courseCourseTests, :tests, :public_courses, :course_offers

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Course" do
      render partial: 'tinymce'
      f.input :name
      f.input :description
      f.input :image
      f.input :package
      f.input :fee
      f.input :public
      f.input :origFee
      f.input :discount
      f.input :type
      f.input :year
      f.input :bestSeller
      f.input :recommended
      f.input :discountedFee
      f.input :expiryAt, as: :date_picker
      f.input :hasVideo
      f.input :hasPartTest
      f.input :allowCallback
    end
    f.actions
  end
end
