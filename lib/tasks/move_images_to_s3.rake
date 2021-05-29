desc "Download the images from external sources and upload them to neetprep s3 bucket and replace their links in notes. # rake move_images_to_s3[startId, endId]"
task :move_images_to_s3, [:start, :stop] => :environment do |task, args|
  ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
  Note.where(%(id BETWEEN ? AND ? AND content like '%<img src="http%'), args[:start],args[:stop]).each do |note|
      p note.id
      content = Nokogiri::HTML(note.content)
      img = content.xpath("//img")
      img.each do |i|
          p i["src"]
          if(!i["src"].start_with?("https://learner-users.s3.ap-south-1.amazonaws.com"))
              url = i["src"]
              filename = "./tmp/my_file." + i["src"].split(".")[-1]
              File.open(filename, "wb") do |file|
                  file.write(HTTParty.get(url).body)
              end      
              j = HTTParty.post(
                    Rails.configuration.node_site_url + 'api/v1/fileUpload/fileUpload',
                    body:{
                      file: File.open(filename, "rb")
                    }
                  )
              s = JSON.parse(j.body)
              p s["location"]
              i["src"] = s["location"]
          end
      end
      note.content = content.to_s
      note.save! 
  end
end
