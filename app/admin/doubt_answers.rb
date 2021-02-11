ActiveAdmin.register DoubtAnswer do
  permit_params :content, :deleted, :imgUrl
  remove_filter :doubt, :user, :versions

  # filter :userId_eq, as: :number, label: "User ID"
  filter :userId_eq, as: :searchable_select, label: "Faculty", :collection => AdminUser.where('"userId" > 0').where(role: ['faculty', 'superfaculty']).distinct_user_id
  filter :doubtId_eq, as: :number, label: "Doubt ID"
  filter :doubt_topic_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  preserve_default_filters!

  scope :all, show_count: false, default: true
  scope :masterclass_answers, show_count: false, default: true

  controller do
    def scoped_collection
      super.includes(:doubt, user: :user_profile)
    end
  end

  index do
    id_column
    column (:content) {|doubt_answer| raw(doubt_answer.content)}
    column :doubt
    column ("Link") {|doubt_answer| link_to "Answer this doubt", '/doubt_answers/answer?doubt_id=' + doubt_answer.doubt.id.to_s, target: ":_blank" }
    column :user
    column :deleted
    if current_admin_user.role == 'admin' or current_admin_user.role == 'faculty' or current_admin_user.role == 'superfaculty'
      @index = 15 * (((params[:page] || 1).to_i) - 1)
      column (:goodFlag) { |doubt_answer|
        if doubt_answer.doubt.goodFlag
          @checkbox = '<label><input type="checkbox" checked id="good_doubt_' + (@index += 1).to_s + '" onchange="onDoubtFlagChange' + @index.to_s + '()"></label>'
        else
          @checkbox = '<label><input type="checkbox" id="good_doubt_' + (@index += 1).to_s + '" onchange="onDoubtFlagChange' + @index.to_s + '()"></label>'
        end
        raw(
          @checkbox + '
            <script>
              var goodFlagCheckbox' + @index.to_s + ' = document.getElementById("good_doubt_' + @index.to_s + '");
              window.onload = function() {
                console.log ("Setting status");
                document.getElementById("good_doubt_' + @index.to_s + '").checked = "' + doubt_answer.doubt.goodFlag.to_s + '" == "false" ? false : true;
              }
              function onDoubtFlagChange' + @index.to_s + '() {
                const url = window.location.origin + "/doubt_answers/toggle_good_flag/";
                $.ajax({
                  type: "POST",
                  url: url,
                  data: {
                    "doubtId": ' + doubt_answer.doubt.id.to_s + ',
                    "value": goodFlagCheckbox' + @index.to_s + '.checked
                  }
                }).done (function (data) {
                  data = null;
                });
              }
            </script>
          '
        )
      }
      else
      column (:goodFlag) { |doubt_answer|
        doubt_answer.doubt.goodFlag
      }
      end
    actions
  end
  
  action_item :doubt_answer_count, only: :index do
    link_to 'Answer Count', '/admin/answer_count'
  end

  form do |f|
    f.inputs "Doubt Answer" do
      render partial: 'tinymce'
      f.input :content
      f.input :deleted
    end
    f.actions
  end
end
