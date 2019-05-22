ActiveAdmin.register SubTopic do
  permit_params :name, :topicId

  form do |f|
    f.inputs "Sub Topic" do
      f.input :name
      f.input :topic
    end
    f.actions
  end

end
