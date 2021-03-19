desc "Extract question and expalnation from content column of Note table and put it in Question table"
task :copynote => :environment do
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
    end
    Note.where("content like '%NEETprep Answer%'").find_each(batch_size:5) do |note|
      htmlContent = Nokogiri::HTML(note.content)
      explanation =  htmlContent.xpath("//div[@class='ncert-exercise-answer']")
      question = note.content.scan(/<\/div>\s*<p.+?<div class="ncert-exercise-answer"/m)  
      if question.length == explanation.length-1
        question.insert(0,"")
      end
      if question.length == explanation.length
        for i in 1..question.length-1
          Question.create(question: question.at(i)[6..-35],explanation:explanation.at(i),type:"SUBJECTIVE",ncert:true)
        end
      end
    end
end