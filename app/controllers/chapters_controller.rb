class ChaptersController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def crud_video
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @videos_data = {}
    @chapterId = params.require(:chapterId)
    @chapter = Topic.find(@chapterId)
    @chapterVideos = @chapter.videos.order(seqId: :asc, id: :asc)
    @chapterVideos.each_with_index do |video, index|
      @videos_data[video.id] = [video.name, index+1]
    end

  end

  def createChapterVideo
    begin
      @chapterId = params[:chapterId]
      @sequenceId = params[:sequenceId]
      @videoIds = params[:videoIds]
      @chapter = Topic.where(id: @chapterId).first
      @rowsArray = []
      video_ids = []

      @chapterVideos = @chapter.videos.order(seqId: :asc, id: :asc)
      @chapterVideos.each do |video|
        video_ids.push(video.id.to_s)
      end

      @videoIds = @videoIds.uniq

      @videoIds = @videoIds - video_ids

      @videoIds.each do |videoId|
        @row = {}
        @row["chapterId"] = @chapter.id
        @row["videoId"] = videoId
        @rowsArray.push(@row)
      end

      if(@videoIds.length() > 0)
        ChapterVideo.create(@rowsArray)
      end

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception
      p exception
    end
  end

  def remove_chapter_video
    begin
      chapterId = params[:chapterId]
      videoIds = params[:videoIds]

      ChapterVideo.where(chapterId: chapterId).where(videoId: videoIds).delete_all

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception

    end
  end

  def update_and_sort_videos
    ids = params[:ids]
    chapterId = params[:chapterId]

    ids.each_with_index do |id, index|
      Video.where(id: id).update_all(seqId: index + 1)
    end

    respond_to do |format|
      format.js
    end
  end

  def crud_question
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @questions_data = {}
    @testId = params.require(:testId)
    @test = Test.find(@testId)
    @testQuestions = @test.questions.order(seqNum: :asc, id: :asc)
    @testQuestions.each_with_index do |question, index|
      @questions_data[question.id] = [question.question, index+1]
    end

  end

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
      if (typesList[index] == 'Video' or typesList[index] == 'Note' or typesList[index] == 'Test') and !SectionContent.exists?(:contentId => id,:sectionId => sectionsList[index].to_i, :contentType => typesList[index])
        SectionContent.create(sectionId: sectionsList[index].to_i, title: titleList[index], contentType: typesList[index], contentId: id, position: index + 1)
      else
        if (typesList[index] == 'Video' or typesList[index] == 'Note' or typesList[index] == 'Test')
          SectionContent.where(contentId: id, contentType: typesList[index], sectionId: sectionsList[index].to_i).update_all(position: index + 1)
        else
          SectionContent.where(id: id).update_all(position: index + 1)
        end
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

    @current_admin_user = current_admin_user
    if current_admin_user.role == 'admin' or current_admin_user.role == 'faculty' or current_admin_user.role == 'support'
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
      testContentIds = []
      @section_contents.each do |section_content|
        section_content.contents.each do |content|
          if content.contentType == 'Video'
            videoContentIds.push(content.contentId)
          elsif content.contentType == 'Note'
            noteContentIds.push(content.contentId)
          elsif content.contentType == 'Test'
            testContentIds.push(content.contentId)
          end
        end
      end

      @section_contents.each_with_index do |section_content, index|
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

        if @chapter.hinglish_videos.length > 0
          @not_linked_chapter_videos = videoContentIds.length > 0 ? @chapter.hinglish_videos.where(['"Video"."id" not in (?)', videoContentIds]).pluck('"Video"."id","Video"."name"') : @chapter.hinglish_videos.pluck('"Video"."id","Video"."name"')
          vidIds = @chapter.hinglish_videos.pluck('"Video"."id"')
        else
          @not_linked_chapter_videos = videoContentIds.length > 0 ? @chapter.videos.where(['"Video"."id" not in (?)', videoContentIds]).pluck('"Video"."id","Video"."name"') : @chapter.videos.pluck('"Video"."id","Video"."name"')
          vidIds = @chapter.videos.pluck('"Video"."id"')
        end

        # added "mathematical tools" videos to show in "motion in a plane" chapter for section content linking
        if @chapterId == '678' or @chapterId == '677'
          @not_linked_chapter_videos += videoContentIds.length > 0 ? Topic.where(id: 676).first.hinglish_videos.where(['"Video"."id" not in (?)', videoContentIds]).pluck('"Video"."id","Video"."name"') : Topic.where(id: 676).first.hinglish_videos.pluck('"Video"."id","Video"."name"')
        end
        testIds = VideoTest.where(videoId: vidIds).pluck('testId')
        @not_linked_chapter_video_tests = Test.where(id: testIds - testContentIds).pluck('"Test"."id","Test"."name"')
        @not_linked_chapter_notes = noteContentIds.length > 0 ? @chapter.notes.where(['"Note"."id" not in (?) and "Note"."description"=(?)', noteContentIds, 'section']).order('"Note"."name"').pluck('"Note"."id","Note"."externalURL"') : @chapter.notes.where(['"Note"."description"=(?)', 'section']).order('"Note"."name"').pluck('"Note"."id","Note"."externalURL"')
        @sections_data[section_content.id] = [section_content.name, contents, index + 1]
      end
    else
      render json: {error: "UnAuthorized Access!", status: 500}.to_json
    end
  end

end
