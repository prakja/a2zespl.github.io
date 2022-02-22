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

    def get_start_url
      response = @@zoom_client.meeting_get meeting_id: @live_class.zoomMeetingId
      response["start_url"]
    end

    def create_meeting!
      response = @live_class.withRegistration ? meeting_with_registration : meeting_with_password_no_registration

      # if with_registration is true we will also store password containing join_url
      update_data = {
        zoomMeetingId: response["id"], 
        joinUrlWithPassword: (response["join_url"] unless @live_class.withRegistration)
      }.compact

      @live_class.update(**update_data)

      response["start_url"]
    end

    private
      def get_meeting_config
        {
          type: 2,
          topic: @live_class.roomName.capitalize,
          user_id: HOST_EMAIL, 
          duration: @live_class.duration, 
          start_time: @live_class.startTime,
        }
      end

      def meeting_with_registration
        @@zoom_client.meeting_create settings: {approval_type: 0, allow_multiple_devices: false}, **get_meeting_config
      end

      def meeting_with_password_no_registration
        password = Digest::SHA2.hexdigest(@live_class.id.to_s).first 10
        @@zoom_client.meeting_create password: password, settings: {approval_type: 2, allow_multiple_devices: false}, **get_meeting_config
      end
  end
end
