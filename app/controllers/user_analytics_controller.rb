class UserAnalyticsController < ApplicationController
  protect_from_forgery with: :null_session
  def show
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

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
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

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

    @easyQuestionsIncorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @easyQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" = "userAnswer"').count
    @mediumQuestionsIncorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @mediumQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" = "userAnswer"').count
    @difficultQuestionsIncorrectCount = Answer.where("\"userId\" = ? AND \"questionId\" IN (?) AND \"testAttemptId\" is ?", @userId, @difficultQuestions, nil).joins(:question).where('"Question"."correctOptionIndex" = "userAnswer"').count

    @easyQuestionAccuracy = 0
    @mediumQuestionAccuracy = 0
    @difficultQuestionAccuracy = 0

    if(@easyQuestionsCorrectCount > 0)
      @easyQuestionAccuracy = 100 * @easyQuestionsCorrectCount / (@easyQuestionsCorrectCount + @easyQuestionsIncorrectCount)
    end

    if(@mediumQuestionsCorrectCount > 0)
      @mediumQuestionAccuracy = 100 * @mediumQuestionsCorrectCount / (@mediumQuestionsCorrectCount + @mediumQuestionsIncorrectCount)
    end

    if(@difficultQuestionsCorrectCount > 0)
      @difficultQuestionAccuracy = 100 * @difficultQuestionsCorrectCount / (@difficultQuestionsCorrectCount + @difficultQuestionsIncorrectCount)
    end

    @accuracy_data = {
      "Easy Questions Accuracy": @easyQuestionAccuracy,
      "Medium Questions Accuracy": @mediumQuestionAccuracy,
      "Difficult Questions Accuracy": @difficultQuestionAccuracy,
    }

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
