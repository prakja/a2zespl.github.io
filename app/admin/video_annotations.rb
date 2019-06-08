ActiveAdmin.register VideoAnnotation do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

permit_params :annotationType, :videoId, :annotationId, :videoTimeStampInSeconds, note_attributes: [:content]

remove_filter :note, :video

form do |f|
  f.inputs "Annotation" do
    f.input :video, as: :fake, value: f.object.video.nil? ? 'No Video Selected' : f.object.video.name
    f.inputs "Note", for: [:note, f.object.note || Note.new] do |n|
      n.input :content
    end
      # f.inputs :for => [
      #   :note,
      #   f.object.note || Note.new
      #   ] do |n_f|
      #     n_f.input :content
      # end
      f.input :annotationType, label: "Annotation type", as: :hidden, :input_html => { :value => 'Note' }
      f.input :videoId, label: "Video", as: :hidden, :input_html => { :value => f.object.videoId }
      f.input :videoTimeStampInSeconds, hint: "To be entered in seconds. Ex: 493 would mean 8 minutes 13 seconds", label: "Show At"
    end
    f.actions
  end

  show do
    attributes_table do
      row ("Content") {resource.note.content}
      row :video
      row :videoTimeMS
    end
  end

  controller do
    def new
      params.permit!
      @video_annotation = VideoAnnotation.new (params[:video_annotation])
      @video_annotation.build_note
    end
  end

end
