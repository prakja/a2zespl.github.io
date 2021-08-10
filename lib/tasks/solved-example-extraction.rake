desc "extracted ncert solved examples with solutions and also inserted into Question table "
task :extraction, [:chapterId] => :environment do |task,args| 
  ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
  # Here we accept a chapter id as input and use that to find notes of that chapter.
  Section.select(%("Section"."id" as sid , "Note"."content" AS content, "Note"."id" as "noteId")).joins(%(INNER JOIN "SectionContent" ON "Section".id = "SectionContent"."sectionId" INNER JOIN "Note" ON "SectionContent"."contentId" = "Note".id)).where(%("Section"."chapterId" = ? AND "SectionContent"."contentType" = 'Note'), args[:chapterId]).order('"Section".id').each do |chapterNote|
    # this section of code is for that notes where example & solutions are both in box div
    sol = false
    htmlContent = Nokogiri::HTML(chapterNote.content)
    p chapterNote.sid
    test = Test.find_or_create_by(name: "#{args[:chapterId]} - NCERT Solved Examples")
    question = nil
    htmlContent.xpath("//div[@class='box']").each do |box|
      boxContent =  box.to_s 
      example = boxContent.scan(/Example.+?Solution/m)
      if example.length != 0
        solution = boxContent.split(/Example.+?Solution/m)
        #solution array has extra element so we have done this to remove the extra element
        solution = solution[1..-1]
        for i in 0..example.length - 1
          e = '<p class="Normal ParaOverride-13" lang="en-US" xml:lang="en-US"><span class="CharOverride-12" lang="en-GB" style="font-weight: bold;" xml:lang="en-GB">' + example[i]
          s = '<p class="Normal ParaOverride-55" lang="en-US" xml:lang="en-US"><span class="CharOverride-12" lang="en-GB" xml:lang="en-GB">Solution' + solution[i]
          p e
          p s 
        #here we taken [0..-9] range because regex was capturing an extra word i.e "solution"
          question = Question.create(question: e[0..-9], explanation: s ,type:"SUBJECTIVE",ncert:true,topicId: args[:chapterId])
          TestQuestion.create(testId: test.id, questionId: question.id)
        end
        sol = true
      end
    end
    # this section of code is for that notes where only example in box div and answer is out of box div
    if sol == false
      answer = htmlContent.to_s.split(/Example.+?Answer/m)
      example =  htmlContent.xpath("//div[@class='box']").map{ |a| a.to_s }

      #answer array has extra element so we have done this to remove the extra element
      answer = answer[1..-1]
      if answer.length != 0 and answer.length == example.length
        for i in 0..example.length - 1
          p example[i]  
          a = '<p class="Body-Text-Indent-2 ParaOverride-43"><span class="CharOverride-7">Answer' + answer[i]
          p a
          question = Question.create(question: example[i], explanation: a ,type:"SUBJECTIVE",ncert:true,topicId: args[:chapterId])
          TestQuestion.create(testId: test.id, questionId: question.id)
        end
      end
    end  
  end 
end
