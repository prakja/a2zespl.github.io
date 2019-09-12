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

  def populate_user_activites
    auth_token = params.require(:auth_token)
    if auth_token == "ff0dc842-551f-4910-a476-516b561c5756"
      users = User.where('"createdAt" >= ?', (Date.current - 10))
      
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
    else
      p "Insure call to API"
      return
    end
  end

end
