class ZoomEventSubscriptionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def meeting_started
    meeting_id = params["payload"]["object"]["id"]

    LiveClass.where(zoomMeetingId: meeting_id).update(live: true)
    render json: {message: :ok}, status: 200
  end

  def meeting_ended
    meeting_id = params["payload"]["object"]["id"]

    LiveClass.where(zoomMeetingId: meeting_id).update(live: false)
    render json: {message: :ok}, status: 200
  end
end
