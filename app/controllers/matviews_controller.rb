class MatviewsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token


  def forced_update
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    begin

    rescue => exception

    end

  end
end
