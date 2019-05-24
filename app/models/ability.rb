class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'faculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:read, :update], [Doubt, DoubtAnswer, Question, Video, Test, CustomerIssue, SubTopic]
    elsif user.role == 'support'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:create, :read, :update], [Question, Test, SubTopic]
    else
      raise 'Unsupported role'
    end
  end
end
