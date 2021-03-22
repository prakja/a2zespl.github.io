desc "Extract question and expalnation from content column of Note table and put it in Question table"
task :copynote, [:chapterId] => :environment do |task, args|
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
    end
    # Here we accept a chapter id as input and use that to find notes of that chapter. 
     Section.select(%("Section".id,"Section"."chapterId" AS chapterId,"Note"."content" AS content)).joins(%(INNER JOIN "SectionContent" ON "Section".id = "SectionContent"."sectionId" INNER JOIN "Note" ON "SectionContent"."contentId" = "Note".id)).where(%("Section"."chapterId" = ? AND "Note"."content" like '%NEETprep Answer%'),args[:chapterId]).find_each(batch_size:5) do |chapterNote|
      htmlContent = Nokogiri::HTML(chapterNote.content)
      explanation =  htmlContent.xpath("//div[@class='ncert-exercise-answer']")
      question = chapterNote.content.scan(/<\/div>\s*<p.+?<div class="ncert-exercise-answer"/m)  
      if question.length == explanation.length-1
        question.insert(0,"")
      end
      if question.length == explanation.length
        nt = Note.find_by(content: chapterNote.content)
        for i in 1..question.length-1
          # Here we taken the range [-6..35]  because  when extracting the question by regex in the starting </div> and in end <div class="ncert-exercise-answer are not part of Question itself so we are leaving that part of regex
          qs = Question.create(question: question.at(i)[6..-35],explanation:explanation.at(i),type:"SUBJECTIVE",ncert:true)
          # Here we will get the id of this quesion from qs.id and replace the explanation in the content of Note from the url https://neetprep.com/ncert/question/qs.id
          url = "https://neetprep.com/ncert-question/" + qs.id.to_s
          explanation.at(i).name = 'a'
          explanation.at(i)['href'] = url
          explanation.at(i)['target'] = '_blank'
          explanation.at(i).content = 'NEETprep Answer'

          #Here we insert the chapterId and questionId to the NcertChapterQuestion table
          NcertChapterQuestion.create(chapterId: args[:chapterId] , questionId:qs.id)
        end
        nt.content = htmlContent.to_html
        nt.save!
      end
    end
end