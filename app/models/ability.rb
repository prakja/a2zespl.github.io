class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'faculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, SubTopic
      can :read, [UserProfile, User, Notification, SubjectLeaderBoard, TopicLeaderBoard, CommonLeaderBoard, TestLeaderBoard, Answer, CourseTest]
      can [:read, :update], [Doubt, DoubtAnswer, Question, Video, Test, CustomerIssue, Note]
      can [:read, :create, :update], [VideoAnnotation, VideoLink]
    elsif user.role == 'support'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, Post, ScheduleItem, Delivery, CustomerSupport, Group, Message]
      can :read, [UserCourse, User, UserProfile]
      can [:create, :read, :update], [Question, Test, Video, CourseInvitation, Payment, TestLeaderBoard]
      can :import, Video
    elsif user.role == 'sales' or user.role == 'sales2'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:read], [Payment, UserCourse, UserAction, User, UserVideoStat]
      can [:create, :read, :update], [CourseInvitation, Delivery, CourseOffer]
    elsif user.role == 'accounts'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:create, :read, :update], [Payment, CourseInvitation, Installment]
    else
      raise 'Unsupported role'
    end
  end
end
