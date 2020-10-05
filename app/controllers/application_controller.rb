class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit

  protected

  def create_token payload
    token = JsonWebToken.encode(payload)
  end

  def user_for_paper_trail
    admin_user_signed_in? ? current_admin_user.try(:id) : 'Unknown user'
  end
end
