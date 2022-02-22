class ZoomEventSubscriptionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def meeting_started
    render json: {message: :ok}, status: 200
  end

  def meeting_ended
    render json: {message: :ok}, status: 200
  end
end
