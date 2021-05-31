desc "Download the images from external sources and upload them to neetprep s3 bucket and replace their links. # rake move_images_to_s3[start, end, column, table, external_link]"
task :move_images_to_s3, [:start, :stop, :column, :table, :ext_link] => :environment do |task, args|
  ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
  query = %(id BETWEEN ? AND ? AND ) +  args[:column] + %( like '%<img src=") + args[:ext_link] + "%'"
  p query
  table = args[:table].constantize
  table.where(query, args[:start],args[:stop]).each do |row|
      p row.id  
      column = Nokogiri::HTML(row[args[:column]])
      img = column.xpath("//img")
      img.each do |i|
          if i["src"].start_with?(args[:ext_link])
              p i["src"]  
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
      row[args[:column]] = column.to_s 
      row.save! 
  end
end
