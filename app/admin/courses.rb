ActiveAdmin.register Course do
  duplicatable
  permit_params :name, :year, :image, :description, :package, :fee, :public, :hasVideo, :hasQuestionBank, :hasNCERT, :hasDoubt, :hasLeaderBoard, :allowCallback, :origFee, :discount, :type, :bestSeller, :recommended, :discountedFee, :expiryAt, :hasPartTest, :shortDescription, :seqId, :feeDesc
  remove_filter :payments, :subjects, :versions, :courseInvitations, :courseCourseTests, :tests, :public_courses, :course_offers

  sidebar :related_data, only: :show do
    ul do
      li link_to "Tests", admin_tests_path(q: {testCourseTests_courseId_eq: course.id}, order: 'startedAt_asc')
      li link_to "Subjects", admin_subjects_path(q: {courseId_eq: course.id}, order: 'id_asc')
    end
  end

  show do
    attributes_table do
      columns_to_exclude = ["description"]
      (Course.column_names - columns_to_exclude).each do |c|
        row c.to_sym
      end
      row :description do |course|
        raw(course.description)
      end
    end
  end

  index do
    id_column
    column :name
    column :description do |course|
      raw(course.description)
    end
    column :shortDescription
    column :package
    column :fee
    column :discountedFee
    column :public
    column :expiryAt
    column ("Course Details") {|course| raw('<a target="_blank" href=/course_details/show?courseId=' + course.id.to_s + '>Course Details</a>')}
    column :seqId
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Course" do
      render partial: 'tinymce'
      f.input :name
      f.input :description
      f.input :shortDescription
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
      f.input :feeDesc
      f.input :seqId
    end
    f.actions
  end

  action_item :sync_course_questions, only: :show, if: proc{ current_admin_user.admin? } do
    link_to 'Sync Course Questions', '/questions/sync_course_questions/' + resource.id.to_s, method: :post, data: {confirm: 'Are you sure? This will potentially modify all questions of the course and even delete unintended questions. Recommended to take a backup of ChapterQuestion before proceeding'}
  end

  member_action :clone_course, method: :post do
    new_resource = resource.clone_course!
    redirect_to admin_course_path(new_resource), notice: "New cloned course created!" 
  end

  action_item :clone_course, only: :show, if: proc{current_admin_user.admin?} do
    link_to 'Clone Course', clone_course_admin_course_path(resource), method: :post 
  end

end
