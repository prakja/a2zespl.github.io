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
    column ("Reinvite Student") { |userCourse|
      #if userCourse.role == "courseStudent"

        # In my defence, it works! ':D

        email = ""
        if userCourse.invitation.nil?
          if not userCourse.user.email.nil?
            email = userCourse.user.email
          elsif userCourse.user.user_profile and not userCourse.user.user_profile.email.nil?
            email = userCourse.user.user_profile.email
          else
            email = ""
          end
        else
          email = userCourse.invitation.email
        end

        phone = ''
        if userCourse.invitation.nil?
          if not userCourse.user.phone.nil?
            phone = userCourse.user.phone
          elsif userCourse.user.user_profile and not userCourse.user.user_profile.phone.nil?
            phone = userCourse.user.user_profile.phone
          else
            phone = ""
          end
        else
          phone = userCourse.invitation.phone
        end

        link_to "Invite", "/admin/course_invitations/new?course_invitation[displayName]=" + (userCourse.user.name || "NEET Student") + "&course_invitation[email]=" + email  + "&course_invitation[phone]=" + phone
      #end
    }
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

  controller do
    def scoped_collection
      # TODO: why is profile not included in include below?
      #  " PG::UndefinedFunction: ERROR:  could not identify an equality operator for type json
      #  LINE 1: ...S t4_r17, "UserProfile"."neetExamYear" AS t4_r18, "UserProfi...
      #   " weeklySchedule is JSON type and on distinct operation, it throws the above error
      super.includes(:course, user: [:user_profile])
    end
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
