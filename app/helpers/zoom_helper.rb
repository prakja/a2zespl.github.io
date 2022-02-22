module ZoomHelper
  class ZoomService
    HOST_EMAIL = "jprakash@goodeducator.com"

    Zoom.configure do |c|
      c.api_key     = "s8F8xZYVR9G9x5gYQ6Ze-g"
      c.api_secret  = "U2MALqmnH8Pq3S4UEFUp3QNlpwuVatN53ZLu"
    end

    @@zoom_client = Zoom.new

    def initialize(live_class)
      @live_class = live_class
    end

    def get_join_url
      response = @@zoom_client.meeting_get meeting_id: @live_class.zoomMeetingId
      response["start_url"]
    end

    def create_meeting!
      response = @@zoom_client.meeting_create(
        user_id: HOST_EMAIL,
        type: 2, duration: @live_class.duration, 
        topic: @live_class.roomName, start_time: @live_class.startTime,
        settings: {approval_type: 0, allow_multiple_devices: false},
      )

      @live_class.update(zoomMeetingId: response["id"])

      response["start_url"]
    end
  end
end
