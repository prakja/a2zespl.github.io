module VideoSentenceHelper
  def parse_transcribe_output(videoId:, json:)
    begin
      video = Video.find videoId
      json_data = JSON.parse(json.read)
    rescue => exception
      return nil
    end

    video_sentences = video.sentences.order(timestampStart: :asc)

    # get an hash containing {44.5 => {:sentence => 'sample', :timestamp_end => 45.5}}
    output_file_timestamps = json_data['results']['items']
      .map { |s| {s["start_time"].to_f => { 
          :sentence => s['alternatives'].first['content'].to_s, 
          :timestamp_end =>  s['end_time'].to_f, :type => s['type'].to_s
        }}}
      .reduce({}, :merge)

    update_video_sentences = []
    video_sentences.each do |sentence|
      sentences_arr = find_sentences_in_range json_sentences: output_file_timestamps,
        lower: sentence.timestampStart, upper: sentence.timestampEnd

      sentence1 = sentences_arr.join(' ')

      unless sentence1.empty?
        sentence.sentence1 = sentence1
        update_video_sentences << sentence
      end
    end

    VideoSentence.import update_video_sentences, on_duplicate_key_update: [:sentence1]
    msg = "Total #{update_video_sentences.length} video sentences updated "

    #merge remaining sentences
    last_video_sentance = video_sentences.last
    remaining_sentences_ts = output_file_timestamps.keys
      .filter { |ts| ts > last_video_sentance.timestampEnd}

    unless remaining_sentences_ts.empty?
      remaining_sentences = remaining_sentences_ts
        .map { |ts| {ts => output_file_timestamps[ts]}}
        .reduce({}, :merge)

      # [{:sentence => 'sample', :start_time=> 4.4, :end_time => 5.5}]
      sentences_arr = group_remaining_sentences sentences: remaining_sentences, limit: 5

      create_sentences = []

      sentences_arr.each do |sentence|
        video_sentence = VideoSentence.new(
          :sentence1 => sentence[:sentence1], :sentence => nil,
          :chapterId => last_video_sentance.chapterId,
          :sectionId => last_video_sentance.sectionId,
          :videoId => last_video_sentance.videoId,
          :timestampStart => sentence[:start_time], 
          :timestampEnd => sentence[:end_time],
          :createdAt => Time.now, :updatedAt => Time.now
        )

        create_sentences << video_sentence
      end

      VideoSentence.import create_sentences
      msg = "#{msg} and #{create_sentences.length} added"
    end

    "#{msg} successfully."
  end

  private
    def find_sentences_in_range(json_sentences:, upper:, lower:)
      # assumption gap between gcp transcribe is greater that of aws
      json_timestamps = json_sentences.keys.sort

      upper_timestamp = json_timestamps.min_by  { |x| (upper - x).abs }
      lower_timestamp = json_timestamps.min_by  { |x| (lower - x).abs }

      # in case the bound exceeds the total timestamps in json file
      return [] if upper_timestamp == lower_timestamp 

      sentences = []

      json_timestamps.each do |ts|
        if ts >= lower_timestamp and ts < upper_timestamp
          sentences << json_sentences[ts][:sentence]
        end
      end

      return sentences
    end

    def group_remaining_sentences(sentences:, limit:) 
      remaining_sentences = []

      sentences = sentences.sort

      tmp, iter = [], 1

      sentences.each do |ts_start, sentence|
        if iter == limit
          tmp, iter = [], 1
          remaining_sentences << tmp
        end

        tmp << sentence.merge({:timestamp_start => ts_start})
        iter = iter + 1 unless sentence[:type] == 'punctuation'
      end

      unless tmp.empty?
        remaining_sentences << tmp
      end

      # merge sentences in tmp array
      remaining_sentences = remaining_sentences.map do |sentence_arr|
        merged_sentence = sentence_arr.map { |rs| rs[:sentence]}.join ' '
        start_time = sentence_arr.first[:timestamp_start]
        end_time = sentence_arr.first[:timestamp_end]

        {:sentence1 => merged_sentence, :start_time => start_time, :end_time => end_time}
      end

      remaining_sentences.uniq { |s| s.values_at(:start_time, :end_time)}
    end
end