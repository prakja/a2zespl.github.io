class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'coach'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
    elsif user.role == 'hindi_editor'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:read, :update], [QuestionTranslation]
    elsif user.role == 'faculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, QuestionHint, ChapterFlashCard, FlashCard]
      can :read, [UserProfile, Notification, SubjectLeaderBoard, TopicLeaderBoard, CommonLeaderBoard, TestLeaderBoard, Answer, CourseTest, Topic, CustomerIssueType, UniqueDoubtAnswer]
      can [:read, :update], [Doubt, User, CustomerIssue, QuestionTranslation]
      can [:read, :create, :update], [VideoAnnotation, VideoLink, DoubtAnswer, Question, Video, Test, Note]
      can [:duplicate_questions, :remove_duplicate, :question_issues], [Topic]
      can [:batch_action], [CustomerIssue]
      can [:create, :read], [ActiveAdmin::Comment]
    elsif user.role == 'superfaculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, QuestionHint, ChapterFlashCard, FlashCard]
      can :read, [UserProfile, Notification, SubjectLeaderBoard, TopicLeaderBoard, CommonLeaderBoard, TestLeaderBoard, Answer, CourseTest, Topic, CustomerIssueType, UniqueDoubtAnswer]
      can [:read, :update], [Doubt, User, CustomerIssue, QuestionTranslation]
      can [:read, :create, :update], [VideoAnnotation, VideoLink, DoubtAnswer, Question, Video, Test, Note]
      can [:duplicate_questions, :remove_duplicate, :question_issues], [Topic]
      can [:batch_action], [CustomerIssue]
      can [:create, :read], [ActiveAdmin::Comment]
    elsif user.role == 'supportAndFaculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, Post, ScheduleItem, Delivery, CustomerSupport, Group, Message, FlashCard, ChapterFlashCard]
      can :read, [UserCourse, UserProfile, CustomerIssueType]
      can [:read, :update], [User, CustomerIssue]
      can [:create, :read, :update], [Question, Test, Video, CourseInvitation, Payment, TestLeaderBoard, SubjectChapter, FlashCard, Note]
      can :import, [Video, FlashCard]
      can :manage, [SubTopic, QuestionHint, ChapterFlashCard, FlashCard]
      can :read, [UserProfile, Notification, SubjectLeaderBoard, TopicLeaderBoard, CommonLeaderBoard, TestLeaderBoard, Answer, CourseTest, Topic, CustomerIssueType, UniqueDoubtAnswer]
      can [:read, :update], [Doubt, DoubtAnswer, Question, Video, Test, CustomerIssue, Note, QuestionTranslation, User]
      can [:read, :create, :update], [VideoAnnotation, VideoLink]
      can [:duplicate_questions, :remove_duplicate, :question_issues], [Topic]
      can [:batch_action], [CustomerIssue]
      can [:create, :read], [ActiveAdmin::Comment]
    elsif user.role == 'support'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, Post, ScheduleItem, Delivery, CustomerSupport, Group, Message, FlashCard, ChapterFlashCard]
      can :read, [UserCourse, UserProfile, CustomerIssueType]
      can [:read, :update], [CustomerIssue, QuestionTranslation, User]
      can [:create, :read, :update], [Question, Test, Video, CourseInvitation, Payment, TestLeaderBoard, SubjectChapter, FlashCard, Note]
      can :import, [Video, FlashCard]
    elsif user.role == 'sales' or user.role == 'sales2'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:read], [Payment, UserCourse, UserAction, User, UserVideoStat, TestAttempt, Test]
      can [:create, :read, :update], [CourseInvitation, Delivery, CourseOffer]
    elsif user.role == 'accounts'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :read, [UserCourse, User, UserProfile]
      can [:create, :read, :update], [Payment, CourseInvitation, Installment]
    else
      raise 'Unsupported role'
    end
  end
end
