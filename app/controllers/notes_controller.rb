class NotesController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def update_content
    begin
      noteId = params[:noteId]
      content = params[:content]
      lock_version = params[:lock_version].to_i

      @note = Note.find(noteId)
      @note.content = content
      @note.lock_version = lock_version
      @note.save!

      respond_to do |format|
        format.html { render :new }
        format.json { render json: {response: "Done"}, status: 200 }
      end

    rescue => exception
      p exception
      format.json { render json: {error: exception.to_s}, status: 500 }
    end
  end

  def duplicate_content
    begin
      noteId = params[:noteId]

      @note = Note.find(noteId)
      duplicateNote = @note.dup
      duplicateNote.save!
      @chapterNote = ChapterNote.where(noteId: noteId).first
      if @chapterNote.present?
        duplicateChapterNote = @chapterNote.dup
        duplicateChapterNote.noteId = duplicateNote.id
        duplicateChapterNote.save!
      end

      respond_to do |format|
        format.html { render :new }
        format.json { render json: {response: "Done", newNoteId: duplicateNote.id}, status: 200 }
      end

    rescue => exception
      p exception
      format.json { render json: {error: exception.to_s}, status: 500 }
    end
  end

  def edit_content
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end
    begin
      @noteId = params.require(:id)
      @note = Note.find(@noteId)
      @content = @note.content != nil ? @note.content : ""
      @lock_version = @note.lock_version

    rescue => exception

    end
  end

end
