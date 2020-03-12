class NotificationsController < ApplicationController
  def send_notification
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end
    @courses = Course.all
    render :layout => false
  end
end
