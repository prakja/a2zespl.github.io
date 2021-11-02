class MatviewsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token


  def forced_update
    authenticate_admin_user!

    begin

    rescue => exception

    end

  end
end
