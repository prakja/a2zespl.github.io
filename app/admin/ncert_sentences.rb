ActiveAdmin.register NcertSentence do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :noteId, :chapterId, :sectionId, :sentence, :createdAt, :updatedAt
  #
  # or
  #
  # permit_params do
  #   permitted = [:noteId, :chapterId, :sectionId, :sentence, :createdAt, :updatedAt]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  remove_filter :note, :chapter, :section, :questions, :questions_count

  filter :chapterId_eq, as: :searchable_select, collection: -> { Topic.name_with_subject_hinglish }, label: "Chapter"
  permit_params :chapterId, :noteId, :sectionId, :sentence, :sentenceHtml
  filter :noteId_eq
  filter :sectionId_eq
  filter :questions_count_eq
  preserve_default_filters!

  form do |f|
    f.inputs "NCERT Sentence" do
      f.input :chapter, input_html: { class: "select2" }, :collection => Topic.name_with_subject_hinglish
      f.input :sectionId
      f.input :noteId
      f.input :sentence
      f.input :sentenceHtml
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column ("Note") {|sentence|
      raw('<a target="_blank" href="/notes/edit_content/' + sentence.noteId.to_s + '">View Note - #' + sentence.noteId.to_s + '</a>')
    }
    column ("Section") {|sentence|
      auto_link(sentence.section)
    }
    column ("Chapter") {|sentence|
      auto_link(sentence.chapter)
    }
    column ("Sentence") {|sentence|
      raw sentence.fullSentenceUrl
    }
    actions
  end

  show do
    attributes_table do
      row :id
      row :note do |sentence|
        raw('<a target="_blank" href="/notes/edit_content/' + sentence.noteId.to_s + '">View Note - #' + sentence.noteId.to_s + '</a>')
      end
      row :section do |sentence|
        auto_link(sentence.section)
      end
      row :chapter do |sentence|
        auto_link(sentence.chapter)
      end
      row :sentence do |sentence|
        sentence.sentence
      end
      row :sentenceHtml do |sentence|
        raw sentence.fullSentenceUrl
      end
      row :questions do |sentence|
        sentence.questions
      end
    end
  end

  controller do
    def find_by_sentence
      sentence = params.require(:sentence)
      ncert_sentence = NcertSentence.where('to_tsvector(\'english\', "sentence") @@ to_tsquery(\'english\', ?)', sentence.gsub(' ', " & "))
      print(ncert_sentence.to_json)
      render json: ncert_sentence.to_json, status: 200
    end

    def scoped_collection
      super.includes(:chapter, :note, :section)
    end
  end

  member_action :mydup do
    ncert_sentence = NcertSentence.find(params[:id])
    @ncert_sentence = ncert_sentence.dup
    render 'active_admin/resource/new.html.arb', layout: false
  end

  action_item "Clone Ncert Sentence", :only => :show do
    link_to("Clone", mydup_admin_ncert_sentence_path(id: resource.id))
  end

end
