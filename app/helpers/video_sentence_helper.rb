module VideoSentenceHelper
  def parse_transcribe_output(videoId:, json:)
    json_data = JSON.parse json.read
    video = Video.find videoId

    video_sentences = video.sentences

    # get an hash containing timestamp => VideoSentence
    hash_video_sentences = video_sentences
      .map { |s| {s.timestampStart => s}}
      .reduce({}, :merge)

    # get an hash containing timestamp => {:sentence => content, :endtime => endtime}
    output_file_timestamps = json_data['results']['items']
      .map { |s| {s["start_time"].to_f => {:sentence => s['alternatives']['content'], :endtime => s['end_time'].to_f}}}
      .reduce({}, :merge)

    # update sentences
    update_timestamps = output_file_timestamps.keys & video_sentences.keys

    unless update_timestamps.empty?
      update_video_sentences = []

      update_timestamps.each do |timestamp|
        video_sentence_instance = hash_video_sentences[timestamp]
        video_sentence_instance.sentence1 = output_file_timestamps[timestamp][:sentence]
        update_video_sentences << video_sentence_instance
      end

      VideoSentence.import update_video_sentences, on_duplicate_key_update: [:sentence1]
    end

    # create new sentences
    new_timestamps = output_file_timestamps.keys - update_timestamps

    unless new_timestamps.empty?
      new_video_sentences = []
      chapterId = ChapterVideo.where(:videoId => videoId).first.chapterId

      new_timestamps.each do |timestamp|
        transcribed_sentence = output_file_timestamps[timestamp][:sentence]
        timestampEndtime = output_file_timestamps[timestamp][:endtime]
  
        new_video_sentences << VideoSentence.new(
          :videoId => videoId, :chapterId => chapterId,
          :timestampStart => timestamp,
          :timestampEnd => timestampEndtime,
          :sentence => nil, :sentence1 => transcribed_sentence, 
          :section => nil
        )
      end

      VideoSentence.import new_video_sentences, validate: false
    end
  end
end