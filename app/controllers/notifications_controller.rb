class NotificationsController < ApplicationController
  def send_notification
    authenticate_admin_user!
    @courses = Course.all
    render :layout => false
  end
end
