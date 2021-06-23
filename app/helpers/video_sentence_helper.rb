module VideoSentenceHelper
  def parse_transcribe_output(videoId:, json:)
    json_data = JSON.parse(json.read)
    video = Video.find videoId

    video_sentences = video.sentences.order(timestampStart: :asc)

    # get an hash containing timestamp => {:sentence => content, :endtime => endtime}
    output_file_timestamps = json_data['results']['items']
      .map { |s| {s["start_time"].to_f => {:sentence => s['alternatives'].first['content'], :endtime => s['end_time'].to_f}}}
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
  end

  private
    def find_sentences_in_range(json_sentences:, upper:, lower:)
      json_timestamps = json_sentences.keys

      upper_timestamp = json_timestamps.min_by  { |x| (upper - x).abs }
      lower_timestamp = json_timestamps.min_by  { |x| (lower - x).abs }

      # in case the bound exceeds the total timestamps in json file
      return [] if upper_timestamp == lower_timestamp 

      sentences = []

      json_timestamps.each do |ts|
        if ts >= lower_timestamp and ts < upper_timestamp
          sentences << json_sentences[timestamp][:sentence]
        end
      end

      return sentences
    end
end