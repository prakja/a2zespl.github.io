class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'faculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, SubTopic
      can :read, UserProfile
      can [:read, :update], [Doubt, DoubtAnswer, Question, Video, Test, CustomerIssue]
    elsif user.role == 'support'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, Post]
      can [:create, :read, :update], [Question, Test]
    else
      raise 'Unsupported role'
    end
  end
end
