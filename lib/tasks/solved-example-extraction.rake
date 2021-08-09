desc "extracted ncert solved examples with solutions and also inserted into Question table "
task :extraction, [:chapterId] => :environment do |task,args| 
  ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
  # Here we accept a chapter id as input and use that to find notes of that chapter.
  Section.select(%("Section"."id" as sid , "Note"."content" AS content, "Note"."id" as "noteId")).joins(%(INNER JOIN "SectionContent" ON "Section".id = "SectionContent"."sectionId" INNER JOIN "Note" ON "SectionContent"."contentId" = "Note".id)).where(%("Section"."chapterId" = ? AND "SectionContent"."contentType" = 'Note'), args[:chapterId]).order('"Section".id').each do |chapterNote|
    # this section of code is for that notes where example & solutions are both in box div
    sol = false
    htmlContent = Nokogiri::HTML(chapterNote.content)
    p chapterNote.sid
    htmlContent.xpath("//div[@class='box']").each do |box|
      boxContent =  box.content 
      example = boxContent.scan(/Example.+?Solution/m)
      if example.length != 0
        solution = boxContent.split(/Example.+?Solution/m)
        #p example
        #p solution[1..-1]


        #solution array has extra element so we have done this to remove the extra element
        solution = solution[1..-1]
        for i in 0..example.length - 1
          #here we taken [0..-9] range because regex was capturing an extra word i.e "solution"
          Question.create(question: example[i][0..-9], explanation: solution[i] ,type:"SUBJECTIVE",ncert:true,topicId: args[:chapterId])
        end
        sol = true
      end
    end
    # this section of code is for that notes where only example in box div and answer is out of box div
    if sol == false
      answer = htmlContent.content.split(/Example.+?Answer/m)
      example =  htmlContent.xpath("//div[@class='box']").map{ |a| a.content }

      #answer array has extra element so we have done this to remove the extra element
      answer = answer[1..-1]
      if answer.length != 0 and answer.length == example.length
        #p example
        #p answer
        for i in 0..example.length - 1
          Question.create(question: example[i], explanation: answer[i] ,type:"SUBJECTIVE",ncert:true,topicId: args[:chapterId])
        end
      end
    end  
  end 
end