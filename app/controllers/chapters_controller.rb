class ChaptersController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token


  def remove_section_content
    begin
      sectionContentId = params[:sectionContentId]
      section_content = SectionContent.where(id: sectionContentId).first

      SectionContent.delete(section_content.id)

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception

    end
  end

  def update_and_sort
    typesList = params[:types]
    sectionsList = params[:sections]
    titleList = params[:titles]

    params[:ids].each_with_index do |id, index|
      if (typesList[index] == 'video' or typesList[index] == 'note') and !SectionContent.exists?(:contentId => id,:sectionId => sectionsList[index].to_i)
        SectionContent.create(sectionId: sectionsList[index].to_i, title: titleList[index], contentType: typesList[index], contentId: id, position: index + 1)
      else
        SectionContent.where(id: id).update_all(position: index + 1)
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def section_content
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @chapters_data = {}
    @ids = [53,54,55,56]
    @chapters = Topic.where(subject: @ids)
    @chapters.each do |chapter|
      @chapters_data[chapter.id] = [chapter.name]
    end

    uri = URI.parse(request.original_url)

    if uri.query
      params = CGI.parse(uri.query)
      @chapterId = params['chapterId'].first ? params['chapterId'].first  : 622
    else
      @chapterId = 622
    end

    @chapter = Topic.where(id: @chapterId).first
    @sections_data = {}
    @section_contents = Section.where(chapterId: @chapter.id).includes(:contents).order('"Section"."position","SectionContent"."position"')

    videoContentIds = []
    noteContentIds = []
    @section_contents.each do |section_content|
      section_content.contents.each do |content|
        if content.contentType == 'video'
          videoContentIds.push(content.contentId)
        elsif content.contentType == 'note'
          noteContentIds.push(content.contentId)
        end
      end
    end

    @section_contents.each do |section_content|
      contents = []
      section_content.contents.each do |content|
        contents.push({
          "id" => content.id,
          "title" => content.title,
          "contentType" => content.contentType,
          "contentId" => content.contentId,
          "position" => content.position,
          "sectionId" => content.sectionId
        })
      end

      not_linked_chapter_videos = videoContentIds.length > 0 ? @chapter.hinglish_videos.where(['"Video"."id" not in (?)', videoContentIds]).pluck('"Video"."id","Video"."name"') : @chapter.hinglish_videos.pluck('"Video"."id","Video"."name"')
      not_linked_chapter_notes = noteContentIds.length > 0 ? @chapter.notes.where(['"Note"."id" not in (?) and "Note"."description"=(?)', noteContentIds, 'section']).pluck('"Note"."id","Note"."externalURL"') : @chapter.notes.where(['"Note"."description"=(?)', 'section']).pluck('"Note"."id","Note"."externalURL"')
      @sections_data[section_content.id] = [section_content.name, contents, not_linked_chapter_videos, not_linked_chapter_notes]
    end
  end

end
