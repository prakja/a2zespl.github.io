ActiveAdmin.register UserCourse do
  permit_params :course, :userId, :courseInvitation, :role, :role, :startedAt, :expiryAt, :courseInvitationId, :courseId
  remove_filter :course, :courseInvitation

  index do
    id_column
    column :course
    column (:userId) { |userCourse| raw(userCourse.userId)  }
    column :courseInvitation
    column (:role) { |userCourse| raw(userCourse.role)  }
    column (:startedAt) { |userCourse| raw(userCourse.startedAt)  }
    column (:expiryAt) { |userCourse| raw(userCourse.expiryAt)  }
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "UserCourse" do
      f.input :course, as: :select, :collection => Course.public_courses
      f.input :userId, label: "User Id"
      f.input :courseInvitation, label: "Course Invitation", as: :select, :collection => CourseInvitation.recent_course_invitations
      f.input :role, as: :select, :collection => ["courseStudent", "courseManager", "courseCreator", "courseAdmin"]
      f.input :startedAt, as: :date_picker, label: "Course start date"
      f.input :expiryAt, as: :date_picker, label: "Course expiry date"
    end
    f.actions
  end
end
