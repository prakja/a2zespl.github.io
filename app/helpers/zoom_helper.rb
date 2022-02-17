module ZoomHelper
  module ServiceHelper
    BASE_URL    = "https://api.zoom.us/v2/"
    API_KEY     = "mtm4O-Z3T-S1xT1eJx3uBg"
    API_SECRET  = "qWxIb5qHYQ9G2zZvdvxPISsyQv90f0ihHTi3"
    JWT_TOKEN   = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOm51bGwsImlzcyI6Im10bTRPLVozVC1TMXhUMWVKeDN1QmciLCJleHAiOjE2NDU3MDAxNjYsImlhdCI6MTY0NTA5NTM2Nn0.c1-lNcXuTGdsDJuZP5VNq9JpyJvLFN7RJ1H_15WalCo" 

    def headers
      {
        'Content-Type': 'application/json', 
        'Accept': 'application/json',
        'Authorization': "Bearer #{JWT_TOKEN}"
      }
    end
  
    def self.included(klass)
      klass.extend(ServiceHelper)
    end
  end
  
  class ZoomService
    include HTTParty
    include ServiceHelper

    def initialize(live_class)
      @live_class = live_class
    end

    def create_meeting
      body = {
        'topic': @live_class.roomName,
        'type': 2,
        'start_time': @live_class.startTime,
        'duration': @live_class.duration
      }
      response = HTTParty.post(BASE_URL + "/users/#{@live_class.zoomEmail}/meetings", body: body.to_json, headers: headers)
      json_response = response.parsed_response

      raise json_response["message"] if response.code >= 400

      @live_class.update(zoomMeetingId: json_response["id"])
      
      json_response["join_url"]
    end

    class << self
      def create_meeting(email:, topic:)
        body = {
          'topic': topic,
          'type': 2,
          'start_time': '2022-02-18T12:02:00Z',
          'duration': 10
        }

        HTTParty.post(BASE_URL + "/users/#{email}/meetings", body: body.to_json, headers: headers)
      end
    end

  end
end
