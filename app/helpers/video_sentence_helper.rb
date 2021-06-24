module VideoSentenceHelper
  def parse_transcribe_output(videoId:, json:)
    video = Video.find videoId

    return nil if video.nil?

    json_data = JSON.parse(json.read)

    video_sentences = video.sentences.order(timestampStart: :asc)

    # get an hash containing timestamp => content
    output_file_timestamps = json_data['results']['items']
      .map { |s| {s["start_time"].to_f => 
          { :sentence => s['alternatives'].first['content'].to_s}, :timestamp_end =>  s['end_time'].to_f}}
      .reduce({}, :merge)

    update_video_sentences = []
    video_sentences.each do |sentence|
      sentences_arr = find_sentences_in_range json_sentences: output_file_timestamps,
        upper: sentence.timestampStart, lower: sentence.timestampEnd

      sentence1 = sentences_arr.join(' ')

      unless sentence1.empty?
        sentence.sentence1 = sentence1
        update_video_sentences << sentence
      end
    end

    VideoSentence.import update_video_sentences

    # merge remaining sentences
    last_video_sentance = video_sentences.last
    remaining_sentences_ts = output_file_timestamps.keys
      .sort.filter { |ts| ts > last_video_sentance.timestampEnd}

    unless remaining_sentences_ts.empty?
      remaining_sentences = remaining_sentences_ts.map { |ts| output_file_timestamps[ts]}

      sentence1 = remaining_sentences.map { |k, v| v[:sentence]}
      sentence1 = sentence1.join(' ')

      # [4.5, {:sentence=> "aaple", :timestamp_end=>4.5}] 
      timestamp_end = remaining_sentences.last.first.first
      timestamp_start = remaining_sentences.first.first.last[:timestamp_end]

      VideoSentence.create(
        :sentence1 => sentence1, :sentence => nil,
        :chapterId => last_video_sentance.chapterId,
        :sectionId => last_video_sentance.sectionId,
        :videoId => last_video_sentance.videoId,
        :createdAt => Time.now, :updatedAt => Time.now,
        :timestampStart => timestamp_start, :timestampEnd => timestamp_end
      )
    end

    "Total #{update_video_sentences.length} video sentences updated and #{remaining_sentences_ts.empty? ? 1 : 0} added"
  end

  private
    def find_sentences_in_range(json_sentences:, upper:, lower:)
      # assumption gap between gcp transcribe is greater that of aws
      json_timestamps = json_sentences.keys

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
end