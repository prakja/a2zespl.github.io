module TechMintHelper
  module ServiceHelper
    BASE_URL  = 'https://api.teachmint.com'
    CLIENT_ID = 'goodedtech'
    AUTH_KEY  = '3wK_gtTAgr2DHkrSwHcWu3G2vsNvXi6aPfLtJmkIaT81sliN6eSnWQ'

    def headers
      {'Content-Type': 'application/json', 'Accept': 'application/json'}
    end
    
    def with_credentials(data)
      {:client_id => CLIENT_ID,:auth_key => AUTH_KEY}.merge(data)
    end
  
    def self.included(klass)
      klass.extend(ServiceHelper)
    end
  end
  
  class TechMintService
    include HTTParty
    include ServiceHelper

    class << self
      def create_room(name, room_id)
        body = with_credentials({'room_id':  room_id.to_s, 'name': name})
        response = HTTParty.post(BASE_URL + "/add/room", body: body.to_json, headers: headers)
        response.parsed_response
      end
  
      def remove_room(room_id)
        body = with_credentials({'room_id':  room_id.to_s})
        response = HTTParty.post(BASE_URL + "/remove/room", body: body.to_json, headers:headers)
        response.parsed_response
      end
    end

    def initialize(room_id:, user:)
      @room_id = room_id
      @user = user
    end

    def student_join
      join_room 3
    end

    def host_join
      join_room 1      
    end

    private
      def join_room(type)
        body = with_credentials({
          'room_id': @room_id.to_s, 
          'user_id': @user.id.to_s,
          'name': @user.email,
          'type': type
        })
    
        response = HTTParty.post(BASE_URL + '/add/user', body: body.to_json, headers: headers)
        raise response.parsed_response.to_s unless response.code == 200

        response.parsed_response["obj"]["url"]
      end
  end
end
