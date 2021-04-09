desc "Extract question and expalnation from content column of Note table and put it in Question table"
task :copynote, [:chapterId] => :environment do |task, args|
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
    end
    p args[:chapterId]
    # Here we accept a chapter id as input and use that to find notes of that chapter.
    Section.select(%("Section".*, "Note"."content" AS content, "Note"."id" as "noteId")).joins(%(INNER JOIN "SectionContent" ON "Section".id = "SectionContent"."sectionId" INNER JOIN "Note" ON "SectionContent"."contentId" = "Note".id)).where(%("Section"."chapterId" = ? AND "SectionContent"."contentType" = 'Note' AND "Note"."content" like '%<div class="ncert-exercise-answer"%'),args[:chapterId]).each do |chapterNote|
      #p chapterNote.chapterId
      #p chapterNote.noteId
      #byebug
      #htmlContent = Nokogiri::HTML(chapterNote.content)
      #explanation =  htmlContent.xpath("//div[@class='ncert-exercise-answer']")
      #TODO: this currently doesn't take care of the fact that <br /> can't come after </div> and whitespace
      question = chapterNote.content.scan(/<\/div>\s*<p.+?<div class="ncert-exercise-answer"/m)  
      explanations = chapterNote.content.split(/<\/div>\s*<p.+?<div class="ncert-exercise-answer"/m)
      firstQuestion = chapterNote.content[/(question|exercise|problem|execises).+?\s*(<p|<div).+?<div class="ncert-exercise-answer"/im]
      q1 = firstQuestion[/<p.*<\/p>/m] || firstQuestion[/<div.*<\/div>/m]
      firstExplanation = explanations.at(0)[/<div class="ncert-exercise-answer".*/m]
      startIndex = 0
      if firstExplanation.nil?
        startIndex = 1
      else
        e1 = firstExplanation + "</div>"
      end
      #if question.length == explanation.length-1
      #  #question.insert(0,"")
      #end
      #p question.length
      #p explanation.length
      #p explanations.length
      if question.length + 1 == explanations.length
        nt = Note.find_by(id: chapterNote.noteId)
        for i in startIndex..explanations.length-1
          # Here we taken the range [-6..35]  because  when extracting the question by regex in the starting </div> and in end <div class="ncert-exercise-answer are not part of Question itself so we are leaving that part of regex
          if i == 0
            q = q1
            e = e1
          else
            q = question.at(i-1)[6..-35]
            if i == explanations.length - 1
              e = '<div class="ncert-exercise-answer"' + explanations.at(i)
            else
              e = '<div class="ncert-exercise-answer"' + explanations.at(i) + '</div>'
            end
          end
          qs = Question.create(question: q,explanation:e,type:"SUBJECTIVE",ncert:true,topicId: args[:chapterId])
          # Here we will get the id of this quesion from qs.id and replace the explanation in the content of Note from the url https://neetprep.com/ncert/question/qs.id
          url = "/ncert-question/" + qs.id.to_s
          completeUrl = '<a target="_blank" href="' + url + '">NEETprep Answer</a>'
          chapterNote.content.gsub!(e, completeUrl)
          #explanation.at(i).name = 'a'
          #explanation.at(i)['href'] = url
          #explanation.at(i)['target'] = '_blank'
          #explanation.at(i).content = 'NEETprep Answer'

          #Here we insert the chapterId and questionId to the NcertChapterQuestion table
          NcertChapterQuestion.create(chapterId: args[:chapterId] , questionId:qs.id)
        end
        nt.content = chapterNote.content
        nt.save!
      end
    end
end
