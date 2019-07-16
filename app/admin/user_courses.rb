ActiveAdmin.register UserCourse do
  permit_params :course, :userId, :role, :startedAt, :expiryAt, :invitationId, :courseId
  remove_filter :course, :versions, :invitation
  preserve_default_filters!

  filter :invitationId_eq, as: :number, label: "Invitation ID"

  index do
    id_column
    column :course
    column (:userId) { |userCourse| raw(userCourse.userId)  }
    column :invitationId
    column ("email") { |userCourse|
      if userCourse.invitation
        userCourse.invitation.email
      end
    }
    column (:role) { |userCourse| raw(userCourse.role)  }
    column :startedAt
    column :expiryAt
    column :createdAt
    actions
  end

  csv do
    column ("course") { |userCourse|
      if userCourse.course
        userCourse.course.name
      end
    }
    column ("email") { |userCourse|
      if userCourse.invitation
        userCourse.invitation.email
      end
    }
    column :startedAt
    column :expiryAt
    column :createdAt
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "UserCourse" do
      f.input :course, as: :select, :collection => Course.public_courses
      f.input :userId, label: "User Id"
      f.input :invitationId, label: "Course Invitation"
      f.input :role, as: :select, :collection => ["courseStudent", "courseManager", "courseCreator", "courseAdmin"]
      f.input :startedAt, as: :date_picker, label: "Course start date"
      f.input :expiryAt, as: :date_picker, label: "Course expiry date"
    end
    f.actions
  end
end
