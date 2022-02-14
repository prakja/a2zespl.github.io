module TechMintHelper
  module ServiceHelper
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
  
    BASE_URL  = 'https://api.teachmint.com'
    CLIENT_ID = 'goodedtech'
    AUTH_KEY  = '3wK_gtTAgr2DHkrSwHcWu3G2vsNvXi6aPfLtJmkIaT81sliN6eSnWQ'
  
    class << self
      def s
        puts "\n\n"
        p "Henlo"
        puts "\n\n"
      end

      def create_room(name, room_id)
        body = with_credentials({'room_id':  room_id.to_s, 'name': name})
        HTTParty.post(BASE_URL + "/add/room", body: body.to_json, headers: headers)
      end
  
      def remove_room(room_id)
        body = with_credentials({'room_id':  room_id.to_s})
        HTTParty.post(BASE_URL + "/remove/room", body: body.to_json, headers:headers)
      end
    end

    def initialize(room_id:, user:)
      @room_id = room_id
      @user = user
    end

    def student_join
      join_room(type: 3)
    end

    def host_join
      join_room(type: 1)      
    end

    private
      def join_room(type)
        body = with_credentials({
          'room_id': @room_id.to_s, 
          'user_id': @user.id.to_s,
          'name': @user.email.split(".").first,
          'type': type
        })
    
        response = HTTParty.post(BASE_URL + '/add/user', body: body.to_json, headers: headers)
        raise response.parsed_response.to_s unless response.code == 200
    
        response.parsed_response["obj"]["url"]
      end
  end
end
