module QuestionKeyword

  # following words are way to ambigous to convey something meaningful and unique
  QUESTION_COMMON_STOPWORDS = [
    "animals", "answer", 
    "body", 
    "called", "cannot", "column", 
    "following", "following", "from", 
    "given", "group", 
    "identify", 
    "life", 
    "many", "match", 
    "name", "number", 
    "option", "organization", 
    "plant", 
    "reaction", "roots", "row", 
    "select", "select", "show", "shown", "statement", "study", "system"
  ]

  def essential_keywords(content, stopwords:[])
    nouns = get_nouns_from_text content
    filter_out_stopwords words: nouns, stopwords: stopwords
  end

  def get_nouns_from_text(text)
    question_text = ActionView::Base.full_sanitizer.sanitize(text)

    tagger = EngTagger.new
    tagged = tagger.add_tags(question_text)

    nouns = tagger.get_nouns(tagged).keys.map { |n| n.downcase.gsub('-', '') }
    nouns.uniq
  end

  def get_stopwords(topic:)
    stopwords = QUESTION_COMMON_STOPWORDS + (topic&.question_stopword&.stopwords || [])
    stopwords.uniq
  end

  def filter_out_stopwords(words:, stopwords:[])
    words.map! { |w| w.gsub(/[^0-9A-Za-z]/, '')} # remove sepcial characters
    words = words.filter { |w| not w.nil? and w.length > 3}
    # compare all the words across stopwords array if any 3 alteration can transform it
    # skip that word
    words.filter { |w| stopwords.find { |sp| levenshtein_distance(w, sp) <= 2}.nil? }
  end

  private
    def levenshtein_distance(str1, str2)
      s, t = str1, str2
      n, m = s.length, t.length
    
      return m if (0 == n)
      return n if (0 == m)
    
      d = (0..m).to_a
      x = nil
    
      # avoid duplicating an enumerable object in the loop
      str2_codepoint_enumerable = str2.each_codepoint
    
      str1.each_codepoint.with_index do |char1, i|
        e = i+1
    
        str2_codepoint_enumerable.with_index do |char2, j|
          cost = (char1 == char2) ? 0 : 1
          x = [
                d[j+1] + 1, # insertion
                e + 1,			# deletion
                d[j] + cost # substitution
              ].min
          d[j] = e
          e = x
        end
        d[m] = x
      end
      x
    end
end