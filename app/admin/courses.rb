ActiveAdmin.register Course do
  permit_params :name, :year, :image, :description, :package, :fee, :public, :hasVideo, :hasQuestionBank, :hasNCERT, :hasDoubt, :hasLeaderBoard, :allowCallback, :origFee, :discount, :type, :bestSeller, :recommended, :discountedFee, :expiryAt, :hasPartTest
  remove_filter :payments, :subjects, :versions, :courseInvitations, :courseCourseTests, :tests, :public_courses, :course_offers

  sidebar :related_data, only: :show do
    ul do
      li link_to "Tests", admin_tests_path(q: {testCourseTests_courseId_eq: course.id}, order: 'startedAt_asc')
    end
  end

  index do
    id_column
    column :name
    column :description do |course|
      raw(course.description)
    end
    column :package
    column :fee
    column :discountedFee
    column :public
    column :expiryAt
    column ("Course Details") {|course| raw('<a target="_blank" href=/course_details/show?courseId=' + course.id.to_s + '>Course Details</a>')}
    actions
  end

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
      f.input :hasQuestionBank
      f.input :hasVideo
      f.input :hasPartTest
      f.input :hasNCERT
      f.input :hasDoubt
      f.input :hasLeaderBoard
      f.input :allowCallback
    end
    f.actions
  end
end
