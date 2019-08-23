ActiveAdmin.register UserCourse do
  permit_params :course, :userId, :role, :startedAt, :expiryAt, :invitationId, :courseId
  remove_filter :course, :versions, :invitation, :user
  preserve_default_filters!

  filter :invitationId_eq, as: :number, label: "Invitation ID"
  filter :userId_eq, as: :number, label: "User ID"
  filter :user_email, as: :string, label: "User Email"
  filter :user_phone, as: :string, label: "User Phone"

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
    column ("user email") { |userCourse|
      if userCourse.user
        userCourse.user.email
      end
    }
    column ("user profile email") { |userCourse|
      if userCourse.user.user_profile
        userCourse.user.user_profile.email
      end
    }
    column ("user phone") { |userCourse|
      if userCourse.user
        userCourse.user.phone
      end
    }
    column ("user profile phone") { |userCourse|
      if userCourse.user.user_profile
        userCourse.user.user_profile.phone
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
    column ("user email") { |userCourse|
      if userCourse.user
        userCourse.user.email
      end
    }
    column ("user profile email") { |userCourse|
      if userCourse.user.user_profile
        userCourse.user.user_profile.email
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
