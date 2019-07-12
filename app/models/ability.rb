class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'faculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, SubTopic
      can :read, UserProfile, User
      can [:read, :update], [Doubt, DoubtAnswer, Question, Video, Test, CustomerIssue]
      can [:read, :create, :update], [VideoAnnotation]
    elsif user.role == 'support'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, Post, ScheduleItem, Delivery, CustomerSupport]
      can :read, UserCourse
      can [:create, :read, :update], [Question, Test, Video, CourseInvitation, Payment]
    elsif user.role == 'sales'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:create, :read], [Payment]
      can [:create, :read, :update], [CourseInvitation, Delivery]
    elsif user.role == 'accounts'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:create, :read, :update], [Payment, CourseInvitation]
    else
      raise 'Unsupported role'
    end
  end
end
