module ZoomHelper
  class ZoomService

    Zoom.configure do |c|
      c.api_key     = "mtm4O-Z3T-S1xT1eJx3uBg"
      c.api_secret  = "qWxIb5qHYQ9G2zZvdvxPISsyQv90f0ihHTi3"
      c.access_token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOm51bGwsImlzcyI6Im10bTRPLVozVC1TMXhUMWVKeDN1QmciLCJleHAiOjE2NDU3MDAxNjYsImlhdCI6MTY0NTA5NTM2Nn0.c1-lNcXuTGdsDJuZP5VNq9JpyJvLFN7RJ1H_15WalCo" 
    end

    @@zoom_client = Zoom.new

    def initialize(live_class)
      @live_class = live_class
    end

    def create_meeting!
      response = @@zoom_client.meeting_create(
        user_id: @live_class.zoomEmail,
        type: 2, duration: @live_class.duration, 
        topic: @live_class.roomName, start_time: @live_class.startTime
      )

      @live_class.update(zoomMeetingId: response["id"])

      response["start_url"]
    end
  end
end
