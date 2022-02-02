ActiveAdmin.register QuestionTranslation do
  remove_filter :ques, :questionTopics, :versions

  permit_params :question, :explanation, :completed, :reviewed
  filter :ques_topicId_in, as: :searchable_select, multiple: true, label: "Question Chapter", :collection => Topic.name_with_subject_hinglish
  filter :topics, as: :searchable_select, multiple: true, label: "Question Bank Chapter", :collection => Topic.name_with_subject_hinglish
  filter :id_eq, as: :number, label: "Translation Id"
  filter :questionId_eq, as: :number, label: "Question Id"
  filter :test_questions, as: :number, label: "Test Id"
  preserve_default_filters!

  index do
    selectable_column
    id_column
    column ("Question") { |qe|
      auto_link(qe.ques)
    }
    column ("Question") { |qe|
      raw(qe.question)
    }
    column ("Explanation") {|qe|
      raw(qe.explanation)
    }
    column ("Chapter") {|qe|
      raw (qe.ques.topic.name)
    }
    actions
  end

  member_action :history do
    @question_translation = QuestionTranslation.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'QuestionTranslation', item_id: @question_translation.id)
    render "layouts/history"
  end

  show do
    render partial: 'mathjax'
    attributes_table do
      row :id
      row :question do |object|
        raw(object.question)
      end
      row :explanation do |object|
        raw(object.explanation)
      end
      row :questionId do |object|
        raw('<a target="_blank" href="/admin/questions/' + object.questionId.to_s + '">' + "Question Link" + '</a>')
      end
      row :chapter do |object|
        raw(object.ques.topic.name)
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Question Translation" do
      render partial: 'tinymce'
      render partial: 'mathjax'
      f.input "Question (English)", as: :fake, value: f.object.ques.nil? ? 'No question linked' : raw(f.object.ques.question)
      f.input :question, input_html: { id: "question_question" }
      f.input "Explanation (English)", as: :fake, value: f.object.explanation.nil? ? 'No question linked' : raw(f.object.ques.explanation)
      f.input :explanation, input_html: { id: "question_explanation" }
      f.input :completed, hint: "Mark completed once ready for review"
      if f.object.completed
        f.input :reviewed, hint: "Mark reviewed if no further editing needed"
      end
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.includes(ques: :topic)
    end
  end

  csv do
    column :id
    column :question
    column :explanation
  end

end
