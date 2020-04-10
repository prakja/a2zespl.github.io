ActiveAdmin.register TestLeaderBoard do
  remove_filter :test, :user, :test_attempt
  preserve_default_filters!
  scope :paid_students, show_count: false
  scope :high_yield_paid_students, show_count: false
  filter :testId_eq, as: :number, label: "Test ID"
  filter :userId_eq, as: :number, label: "User ID"
  filter :test_attempt_createdAt, as: :date_range, label: "Test Attempt Date"

  controller do
    def scoped_collection
      super.includes(:test, :test_attempt, user: :user_profile)
    end
  end

  csv do
    column :rank
    column (:user) { |tlb|
      raw(tlb.user&.user_profile&.displayName)
    }
    column (:email) { |tlb|
      raw(tlb.user.email || tlb.user&.user_profile&.email)
    }
    column (:phone) { |tlb|
      raw(tlb.user.phone || tlb.user&.user_profile&.phone )
    }
    column :score
    column (:correctAnswerCount) { |test_attempt|
      test_attempt.correctAnswerCount
    }
    column (:incorrectAnswerCount) { |test_attempt|
      test_attempt.incorrectAnswerCount
    }
  end

  index do
    column :id
    column :rank
    column :user
    column (:email) { |tlb|
      raw(tlb.user.email || tlb.user&.user_profile&.email)
    }
    column (:phone) { |tlb|
      raw(tlb.user.phone || tlb.user&.user_profile&.phone )
    }
    column :test
    column :test_attempt
    column :score
    column (:correctAnswerCount) { |test_attempt|
      raw('<a target="_blank" href=answers?q[userId_eq]='+test_attempt.userId.to_s+'&scope=correct_answers&q[testAttemptId_eq]=' + test_attempt.id.to_s + '>' + test_attempt.correctAnswerCount.to_s + '</a>')
    }
    column (:incorrectAnswerCount) { |test_attempt|
      raw('<a target="_blank" href=answers?q[userId_eq]='+test_attempt.userId.to_s+'&scope=incorrect_answers&q[testAttemptId_eq]=' + test_attempt.id.to_s + '>' + test_attempt.incorrectAnswerCount.to_s + '</a>')
    }
    column "Time Taken" do |testLeaderBoard|
      raw(((testLeaderBoard.test_attempt.updatedAt - testLeaderBoard.test_attempt.createdAt) / 60).round.to_s + " minutes")
    end
    actions
  end

end
