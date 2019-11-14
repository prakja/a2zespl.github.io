class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'faculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, SubTopic
      can :read, [UserProfile, User, Notification, SubjectLeaderBoard, TopicLeaderBoard, CommonLeaderBoard, TestLeaderBoard, Answer]
      can [:read, :update], [Doubt, DoubtAnswer, Question, Video, Test, CustomerIssue, Note]
      can [:read, :create, :update], [VideoAnnotation]
    elsif user.role == 'support'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, Post, ScheduleItem, Delivery, CustomerSupport]
      can :read, UserCourse
      can [:create, :read, :update], [Question, Test, Video, CourseInvitation, Payment, TestLeaderBoard]
      can :import, Video
    elsif user.role == 'sales'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:read], [Payment, CourseInvitation, UserCourse, UserAction]
      can [:create, :read, :update], [Delivery]
    elsif user.role == 'sales2'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:read], [Payment, UserCourse]
      can [:create, :read, :update], [CourseInvitation, Delivery]
    elsif user.role == 'accounts'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:create, :read, :update], [Payment, CourseInvitation, Installment]
    else
      raise 'Unsupported role'
    end
  end
end
