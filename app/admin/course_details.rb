ActiveAdmin.register CourseDetail do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :courseId, :description, :shortDescription, :rating, :ratingCount, :enrolled, :language, :videoUrl, :bestseller, :curriculum, :features, :requirements, :createdAt, :updatedAt
  #
  # or
  #
  # permit_params do
  #   permitted = [:courseId, :description, :shortDescription, :rating, :ratingCount, :enrolled, :language, :videoUrl, :bestseller, :curriculum, :features, :requirements, :createdAt, :updatedAt]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  json_editor

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Course Details" do
      render partial: 'tinymce'
      f.input :courseId
      f.input :description
      f.input :shortDescription
      f.input :rating
      f.input :ratingCount
      f.input :enrolled
      f.input :language
      f.input :videoUrl
      f.input :bestseller
      f.input :curriculum, as: :text, input_html: { class: 'jsoneditor-target' }
      f.input :features, as: :text, input_html: { class: 'jsoneditor-target' }
      f.input :requirements, as: :text, input_html: { class: 'jsoneditor-target' }
    end
    f.actions
  end
  
end
