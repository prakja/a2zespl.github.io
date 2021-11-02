class UserAnalyticsController < ApplicationController
  protect_from_forgery with: :null_session

  def userData
    authenticate_admin_user!

    if request.post?
      emails = params[:emails].split(/\r?\n/)
      ids = User.where(email: emails).select("id").all
      ids = (ids + UserProfile.where(email: emails).select("userId").all).uniq
      phone_numbers = params[:phone_numbers].split(/\r?\n/)
      related_phone_numbers = []
      phone_numbers.each do |number|
        related_phone_numbers << '+91' + number.split(//).last(10).join
        related_phone_numbers << '0' + number.split(//).last(10).join
        related_phone_numbers << number.split(//).last(10).join
      end
      related_phone_numbers.uniq!
      ids = (ids + User.where(phone: related_phone_numbers).select("id").all).uniq
      ids = (ids + UserProfile.where(phone: related_phone_numbers).select("userId").all).uniq
      # get ids on above emails & phone numbers
      @users = User.where(id: ids).select('"User".*, COUNT("Answer"."id") / case COUNT(distinct("UserCourse"."courseId")) when 0 then 1 else COUNT(distinct("UserCourse"."courseId")) end as "answerCount", array_agg(distinct("UserCourse"."courseId")) as "courseIds", array_agg(distinct("UserProfile"."phone")) as "userProfilePhone", array_agg(distinct("UserProfile"."email")) as "userProfileEmail"').joins('LEFT OUTER JOIN "Answer" ON ("Answer"."userId" = "User"."id")').joins('LEFT OUTER JOIN "UserCourse" ON ("UserCourse"."userId" = "User"."id") and "expiryAt" - "startedAt" > INTERVAL \'10 days\' and "trial" = false and "expiryAt" > \'2020-08-12\'').joins('LEFT OUTER JOIN "UserProfile" ON ("UserProfile"."userId" = "User"."id")').group('"User"."id"');
    end
  end

  def show
    authenticate_admin_user!

    @userId = params.require(:userId)
    startDate = [params[:startDate]][0]
    endDate = [params[:endDate]][0]

    if startDate.blank? && endDate.blank?
      endDate = Date.current
      startDate = (endDate - 10)
      redirect_to "/user_analytics/show?userId=" + @userId.to_s + "&startDate=" + startDate.year.to_s + "-" + startDate.month.to_s.rjust(2, '0') + "-" + startDate.day.to_s.rjust(2, '0') + "&endDate=" + endDate.year.to_s + "-" + endDate.month.to_s.rjust(2, '0') + "-" + endDate.day.to_s.rjust(2, '0')
      return
    end

    @reponse = HTTParty.post(
      "https://analytics.neetprep.com/index.php?doNotFetchActions=0&filter_limit=401&format=JSON2&idSite=1&method=Live.getLastVisitsDetails&module=API&period=range&segment=userId%3D%3D" + @userId + "&date=" + startDate.to_s + "," + endDate.to_s,
      body: {
        token_auth: 'dbe0f60a3c17cc16002ba9b00591b81d'
      }
    )

    @objects = JSON.parse(@reponse.to_s)
  end

  def accuracy
    authenticate_admin_user!

    @userId = params[:userId]
    @user = User.where(id: @userId).first
    @userName = 'NEET Student'

    if @user.user_profile != nil
      if @user.user_profile.displayName != nil
        @userName = @user.user_profile.displayName
      end
    end

    @courses_data = {}
    @courses = Course.public_courses
    @courses.each do |course|
      @courses_data[course.id] = [course.name]
    end
  end

  def showAccuracy
    @accuracy_data = {}
    @topicId = params.require(:chapterId)
    @userId = params.require(:userId)
    @topic = Topic.find(@topicId)
    @easyQuestions = @topic.questions.joins(:question_analytic).where("\"QuestionAnalytics\".\"difficultyLevel\" in ('easy')").pluck(:id)
    @mediumQuestions = @topic.questions.joins(:question_analytic).where("\"QuestionAnalytics\".\"difficultyLevel\" in ('medium')").pluck(:id)
    @difficultQuestions = @topic.questions.joins(:question_analytic).where("\"QuestionAnalytics\".\"difficultyLevel\" in ('difficult')").pluck(:id)

    @easyQuestionsCorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @easyQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" = "userAnswer"').count
    @mediumQuestionsCorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @mediumQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" = "userAnswer"').count
    @difficultQuestionsCorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @difficultQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" = "userAnswer"').count

    @easyQuestionsIncorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @easyQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" != "userAnswer"').count
    @mediumQuestionsIncorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @mediumQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" != "userAnswer"').count
    @difficultQuestionsIncorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @difficultQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" != "userAnswer"').count

    @easyQuestionAccuracy = nil
    @mediumQuestionAccuracy = nil
    @difficultQuestionAccuracy = nil

    if(@easyQuestionsCorrectCount + @easyQuestionsIncorrectCount > 0)
      @easyQuestionAccuracy = 100 * @easyQuestionsCorrectCount / (@easyQuestionsCorrectCount + @easyQuestionsIncorrectCount)
    end

    if(@mediumQuestionsCorrectCount + @mediumQuestionsIncorrectCount > 0)
      @mediumQuestionAccuracy = 100 * @mediumQuestionsCorrectCount / (@mediumQuestionsCorrectCount + @mediumQuestionsIncorrectCount)
    end

    if(@difficultQuestionsCorrectCount + @difficultQuestionsIncorrectCount > 0)
      @difficultQuestionAccuracy = 100 * @difficultQuestionsCorrectCount / (@difficultQuestionsCorrectCount + @difficultQuestionsIncorrectCount)
    end

    @accuracy_data = {
      "Easy" => {
        "Total": @easyQuestions.length(),
        "Attempted": @easyQuestionsCorrectCount + @easyQuestionsIncorrectCount,
        "Correct": @easyQuestionsCorrectCount,
        "Accuracy": @easyQuestionAccuracy
      },
      "Medium" => {
        "Total": @mediumQuestions.length(),
        "Attempted": @mediumQuestionsCorrectCount + @mediumQuestionsIncorrectCount,
        "Correct": @mediumQuestionsCorrectCount,
        "Accuracy": @mediumQuestionAccuracy
      },
      "Difficult" => {
        "Total": @difficultQuestions.length(),
        "Attempted": @difficultQuestionsCorrectCount + @difficultQuestionsIncorrectCount,
        "Correct": @difficultQuestionsCorrectCount,
        "Accuracy": @difficultQuestionAccuracy
      }
    }

    p @accuracy_data.to_json

    respond_to do |format|
      format.html { render :new }
      format.json { render json: @accuracy_data.to_json, status: 200 }
    end
  end

  def populate_user_activites
    auth_token = params.require(:auth_token)
    if auth_token == "ff0dc842-551f-4910-a476-516b561c5756"
      users = User.where('"createdAt" >= ? and "User"."id" NOT IN (SELECT "userId" from "UserCourse")', (Date.current - 10))

      users.each do |user|
        userId = user[:id]
        reponse = HTTParty.post(
          "https://analytics.neetprep.com/index.php?doNotFetchActions=0&filter_limit=401&format=JSON2&idSite=1&method=Live.getLastVisitsDetails&module=API&period=range&segment=userId%3D%3D" + userId.to_s + "&date=" + (Date.current - 10).to_s + "," + Date.current.to_s,
          body: {
            token_auth: 'dbe0f60a3c17cc16002ba9b00591b81d'
          }
        )
        objects = JSON.parse(reponse.to_s)
        action_count = 0
        objects.each do |object|
          action_count += object["actions"].to_i
        end
        UserAction.find_or_create_by(userId: userId) do |user|
          user.count = action_count
        end
      end
      respond_to do |format|
        format.json { render json: "success" }
      end
    else
      p "Insure call to API"
      return
    end
  end

end
