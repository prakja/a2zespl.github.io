class NotesController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def update_content
    begin
      noteId = params[:noteId]
      content = params[:content]

      Note.where(id: noteId).update_all(content: content.to_s)

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception

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

    rescue => exception

    end
  end

end
