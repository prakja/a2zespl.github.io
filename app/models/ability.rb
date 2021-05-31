class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'coach'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :read, [StudentCoach]
    elsif user.role == 'hindi_editor'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:read, :update], [QuestionTranslation]
    elsif user.role == 'faculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, QuestionHint, ChapterFlashCard, FlashCard]
      can :read, [UserProfile, Notification, SubjectLeaderBoard, TopicLeaderBoard, CommonLeaderBoard, TestLeaderBoard, Answer, CourseTest, Topic, CustomerIssueType, UniqueDoubtAnswer, ChapterQuestion, TestAttempt]
      can [:read, :update], [Doubt, User, CustomerIssue, QuestionTranslation, NcertSentence, VideoSentence, DuplicateQuestion, NotDuplicateQuestion]
      can [:read, :create, :update], [VideoAnnotation, VideoLink, DoubtAnswer, Question, Video, Test, Note, WorkLog]
      can [:mark_not_duplicate, :duplicate_questions, :remove_duplicate, :question_issues], [Topic]
      can [:mark_not_duplicate, :duplicate_questions, :mark_duplicate], [SubTopic]
      can [:duplicate_questions, :remove_duplicate], [Test]
      can [:batch_action], [CustomerIssue, DuplicateQuestion, NotDuplicateQuestion]
      can [:create, :read], [ActiveAdmin::Comment]
      can [:play], [Video]
      can [:destroy], [DuplicateQuestion, NotDuplicateQuestion]
    elsif user.role == 'superfaculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, QuestionHint, ChapterFlashCard, FlashCard]
      can :read, [UserProfile, Notification, SubjectLeaderBoard, TopicLeaderBoard, CommonLeaderBoard, TestLeaderBoard, Answer, CourseTest, Topic, CustomerIssueType, UniqueDoubtAnswer, ChapterQuestion, TestAttempt]
      can [:read, :update], [Doubt, User, CustomerIssue, QuestionTranslation, NcertSentence, VideoSentence, DuplicateQuestion, NotDuplicateQuestion]
      can [:read, :create, :update], [VideoAnnotation, VideoLink, DoubtAnswer, Question, Video, Test, Note, WorkLog]
      can [:mark_not_duplicate, :duplicate_questions, :remove_duplicate, :question_issues], [Topic]
      can [:mark_not_duplicate, :duplicate_questions, :mark_duplicate], [SubTopic]
      can [:duplicate_questions, :remove_duplicate], [Test]
      can [:batch_action], [CustomerIssue, DuplicateQuestion, NotDuplicateQuestion]
      can [:create, :read], [ActiveAdmin::Comment]
      can [:play], [Video]
      can [:destroy], [DuplicateQuestion, NotDuplicateQuestion]
    elsif user.role == 'supportAndFaculty'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, Post, ScheduleItem, Delivery, CustomerSupport, Group, Message, FlashCard, ChapterFlashCard]
      can :read, [UserCourse, UserProfile, CustomerIssueType]
      can [:read, :update], [User, CustomerIssue]
      can [:create, :read, :update], [Question, Test, Video, CourseInvitation, Payment, TestLeaderBoard, SubjectChapter, FlashCard, Note, WorkLog]
      can :import, [Video, FlashCard]
      can :manage, [SubTopic, QuestionHint, ChapterFlashCard, FlashCard]
      can :read, [UserProfile, Notification, SubjectLeaderBoard, TopicLeaderBoard, CommonLeaderBoard, TestLeaderBoard, Answer, CourseTest, Topic, CustomerIssueType, UniqueDoubtAnswer, ChapterQuestion, TestAttempt]
      can [:read, :update], [Doubt, DoubtAnswer, Question, Video, Test, CustomerIssue, Note, QuestionTranslation, User, NcertSentence, VideoSentence, DuplicateQuestion, NotDuplicateQuestion]
      can [:read, :create, :update], [VideoAnnotation, VideoLink]
      can [:mark_not_duplicate, :duplicate_questions, :remove_duplicate, :question_issues], [Topic]
      can [:mark_not_duplicate, :duplicate_questions, :mark_duplicate], [SubTopic]
      can [:duplicate_questions, :remove_duplicate], [Test]
      can [:batch_action], [CustomerIssue, DuplicateQuestion, NotDuplicateQuestion]
      can [:create, :read], [ActiveAdmin::Comment]
      can [:play], [Video]
      can [:destroy], [DuplicateQuestion, NotDuplicateQuestion]
    elsif user.role == 'support'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :manage, [SubTopic, Post, ScheduleItem, Delivery, CustomerSupport, Group, Message, FlashCard, ChapterFlashCard]
      can :read, [UserCourse, UserProfile, CustomerIssueType, TestAttempt]
      can [:read, :update], [CustomerIssue, QuestionTranslation, User, VideoSentence]
      can [:create, :read, :update], [Question, Test, Video, CourseInvitation, Payment, TestLeaderBoard, SubjectChapter, FlashCard, Note, WorkLog]
      can :import, [Video, FlashCard]
      can [:play], [Video]
    elsif user.role == 'sales' or user.role == 'sales2'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can [:read], [Payment, UserCourse, UserAction, User, UserVideoStat, TestAttempt, Test]
      can [:create, :read, :update], [CourseInvitation, Delivery, CourseOffer, WorkLog]
    elsif user.role == 'accounts'
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :read, [UserCourse, User, UserProfile]
      can [:create, :read, :update], [Payment, CourseInvitation, Installment, WorkLog]
    else
      raise 'Unsupported role'
    end
  end
end
