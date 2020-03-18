namespace :merge do
  desc "Let's do this!"

  task :merge_notes => :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    ARGV.each do |argv|
      sections = Section.where(chapterId: [argv.to_i]).order('"chapterId","position"')

      sections.each_with_index do |section, ind|
        section_contents = SectionContent.where(sectionId: section.id).order("position")
        global_array = []
        temp = []

        length_sum = 0

        section_contents.each_with_index do |section_content, index|
          if section_content.contentType == 'note' and length_sum < 5000
            if index == (section_contents.count - 1)
              htmlContent = Note.find(section_content.contentId).content.gsub!(/<link.*?>|<\/>/, '')
              if htmlContent.length > 1000
                global_array.push(temp) if not temp.empty?
                temp = []
                temp.push(section_content.contentId)
                global_array.push(temp) if not temp.empty?
                length_sum = 0
              end
            else
              p section_content.contentId.to_s + " :<5000"
              temp.push(section_content.contentId)
              htmlContent = Note.find(section_content.contentId).content.gsub!(/<link.*?>|<\/>/, '')
              length_sum += htmlContent.length if not htmlContent.nil?
            end
            
          elsif section_content.contentType == 'note' and length_sum >= 5000
            p section_content.contentId.to_s + " :>5000"
            global_array.push(temp) if not temp.empty?
            temp = []
            temp.push(section_content.contentId)
            htmlContent = Note.find(section_content.contentId).content.gsub!(/<link.*?>|<\/>/, '')
            length_sum = 0
            length_sum += htmlContent.length if not htmlContent.nil?
            if index == (section_contents.count - 1)
              global_array.push(temp) if not temp.empty?
              temp = []
              length_sum = 0
            end
          elsif section_content.contentType != 'note'
            global_array.push(temp) if not temp.empty?
            temp = []
            length_sum = 0
          end
        end

        p "Fixing Section ID: " + section.id.to_s
        p "global_array: " + global_array.to_s

        global_array.each_with_index do |note_group, indx|
          merge(note_group) if note_group.count > 1
        end
      end
    end
  end

  def merge(note_arr)
    p "merge " + note_arr.to_s
    htmlContent = ''
    note_arr.each_with_index do |note_id, index|
      if index == 0
        htmlContent += Note.find(note_id).content
      else
        htmlContent += Note.find(note_id).content.gsub!(/<link.*?>|<\/>/, '')
        section_content_to_delete = SectionContent.where(contentType: 'note', contentId: note_id).first
        SectionContent.delete(section_content_to_delete.id)
      end
    end

    first_note = Note.find(note_arr[0])
    first_note.update({
      content: htmlContent
    })
  end

end
