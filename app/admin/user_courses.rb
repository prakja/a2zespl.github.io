ActiveAdmin.register UserCourse do
  permit_params :course, :userId, :role, :startedAt, :expiryAt, :invitationId, :courseId
  remove_filter :course, :versions, :invitation, :user
  preserve_default_filters!

  filter :invitationId_eq, as: :number, label: "Invitation ID"
  filter :userId_eq, as: :number, label: "User ID"
  filter :user_email, as: :string, label: "User Email"
  filter :user_phone, as: :string, label: "User Phone"

  scope "Active Courses", :active, default: true
  scope "Active Trial Courses", :active_trial_courses
  scope "Inactive Trial Courses", :inactive_trial_courses, :show_count => false
  scope "Duration > 10 days", :duration_10_days, :show_count => false
  scope "Achiever Batch Only", :achiever_batch_access_only, :show_count => false
  scope "Inspire Batch Only", :inspire_batch_access_only, :show_count => false
  scope :all, :show_count => false

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
      if userCourse.user and userCourse.user.phone
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

        link_to "Invite", "/admin/course_invitations/new?course_invitation[displayName]=" + (userCourse.user.name || "NEET Student") + "&course_invitation[email]=" + email.to_s  + "&course_invitation[phone]=" + phone.to_s + "&course_invitation[expiryAt]=30/06/2020"
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
    column ("user profile name") { |userCourse|
      if userCourse.user.user_profile
        userCourse.user.user_profile.displayName
      end
    }
    column ("user profile email") { |userCourse|
      if userCourse.user.user_profile
        userCourse.user.user_profile.email
      end
    }
    column ("user phone") { |userCourse|
      if userCourse.user and userCourse.user.phone
        userCourse.user.phone
      end
    }
    column ("user profile phone") { |userCourse|
      if userCourse.user.user_profile
        userCourse.user.user_profile.phone
      end
    }
    column :startedAt
    column :expiryAt
  end

  controller do
    def scoped_collection
      super.includes(:course, user: [:user_profile])
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "UserCourse" do
      f.input :course, include_hidden: false, input_html: { class: "select2" }, :collection => Course.public_courses, hint: "Search course by name or select from list"
      f.input :userId, label: "User Id"
      f.input :invitationId, label: "Course Invitation"
      f.input :role, as: :select, :collection => ["courseStudent", "courseManager", "courseCreator", "courseAdmin"]
      f.input :startedAt, as: :date_picker, label: "Course start date"
      f.input :expiryAt, as: :date_picker, label: "Course expiry date"
    end
    f.actions
  end
end
