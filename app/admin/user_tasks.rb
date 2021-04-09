ActiveAdmin.register UserTask do
  remove_filter :task, :user
  permit_params :createdAt, :updatedAt, :userId, :task, :taskId, :hours

  form do |f|
    f.inputs "User Task" do
      f.input :userId
      f.input :task
      f.input :hours
    end
    f.actions
  end

  index do
    id_column
    column :task
    column (:user) {|user_task|
    raw('<a target="_blank" href="../admin/users/' + user_task.user.id.to_s + '">' + user_task.user.name + '</a>')      
    }
    column :hours
    actions
  end  
end
