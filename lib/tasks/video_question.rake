namespace :video_question do
  desc "import video timestamp based questions"
  task test: :environment do 
    p "We here"
  end

  task import_question: :environment do 
    ARGV.each { |a| task a.to_sym do ; end }
    video_id = ARGV[1].to_i
    test_name = ARGV[2]
    question = ARGV[3]
    correct_option_index = ARGV[4]
    timestamp = ARGV[5]
    p test_name
    test = nil
    video_test = VideoTest.find_by videoId: video_id
    if video_test.nil?
      # test = Test.create!(name: test_name, positiveMarks: 4, negativeMarks: 1)
      # VideoTest.create!(videoId: video_id, testId: test.id)
      p "Create Test and Video Test"
    else
      test = Test.find(video_test.testId)
      if test.positiveMarks.blank? or test.negativeMarks.blank?
        test.positiveMarks = 4
        test.negativeMarks = 1
        # test.save!
        p "Update Test"
      end
    end
    # q = Question.create!(question: question_content, correctOptionIndex: correct_option_index)
    # VideoQuestion.create!(videoId: video_id, questionId: q.id, timestamp: timestamp)
    # TestQuestion.create!(testId: test.id, questionId: q.id)
    p "Create Question and VideoQuestion and TestQuestion"
  end

  task import: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    # Read Text File and get questions
    file_name = ARGV[1]
    video_id = ARGV[2].to_i;
    file_content = File.read(file_name)
    questions = file_content.scan(/[0-9]{2}[:;][0-9]{2}.*?Answer.*?\)/m)
    test_name = file_name.gsub(".docx", "").gsub(".txt", "").gsub(/.*\//, "")
    p test_name
    test = nil
    video_test = VideoTest.find_by videoId: video_id
    if video_test.nil?
      test = Test.create!(name: test_name, positiveMarks: 4, negativeMarks: 1)
      VideoTest.create!(videoId: video_id, testId: test.id)
    else
      test = Test.find(video_test.testId)
      if test.positiveMarks.blank? or test.negativeMarks.blank?
        test.positiveMarks = 4
        test.negativeMarks = 1
        test.save!
      end
    end
    questions.each do |question|
      match_data = question.match(/([0-9]{2})[:;]([0-9]{2})(.*?)Answer[ :;]+\((.*?)\)\s?/m)
      if not match_data.nil? and match_data.length == 5
        timestamp = match_data[1].to_i * 60 + match_data[2].to_i
        question_content = match_data[3].gsub("\r\n", "<br />")
        correct_option_index = match_data[4].to_i - 1;
        q = Question.create!(question: question_content, correctOptionIndex: correct_option_index)
        VideoQuestion.create!(videoId: video_id, questionId: q.id, timestamp: timestamp)
        TestQuestion.create!(testId: test.id, questionId: q.id)
        p timestamp
        p question_content
        p correct_option_index
      else
        puts "\e[41m" + "question data not as expected" + "\e[0m"
        puts "\e[31m" + question + "\e[0m"
        p match_data
      end
    end
  end
end
