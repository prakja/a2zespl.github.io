namespace :chapterwise_test do
  # rake chapterwise_test:ncert_free[1087427, 1087426]

  desc "Create ncert chapterwise tests using questions from specific test"

  task :ncert_free, [:ncert_solved, :ncert_back, :subject_id] => :environment do |t, args|
    args.with_defaults(:ncert_solved => 1138155, :ncert_back => 1020201, :subject_id => 55) # by default physics

    ncert_solved_test_id, ncert_back_test_id = args[:ncert_solved].to_i, args[:ncert_back].to_i
    subject_id = args[:subject_id].to_i

    topics = Topic.where(:subjectId => subject_id)

    ActiveRecord::Base.transaction do
      topics.each do |topic|
        sections, test_questions = [], []

        test_title = "#{topic.name} NCERT Example & Excercise Based MCQs"

        topic_test = Test.create!(
          :name => test_title, :description => test_title,
          :free => true, :showAnswer => true,
          :positiveMarks => 4, :negativeMarks => 1
        )

        ncert_solved_question_ids = Question
          .joins(:tests)
          .where(Question: {:topicId => topic.id}, TestQuestion: {:testId => ncert_solved_test_id})
          .pluck(:id)

        if ncert_solved_question_ids.length > 0
          sections << ["Solved Examples", 1]
          test_questions << ncert_solved_question_ids
            .map { |qId| TestQuestion.new(:testId => topic_test.id, :questionId => qId, :seqNum => 0)}
        end

        ncert_backed_question_ids = Question
          .joins(:tests)
          .where(Question: {:topicId => topic.id}, TestQuestion: {:testId => ncert_back_test_id})
          .pluck(:id)

        if ncert_backed_question_ids.length > 0
          sections << ["Back Exercises", ncert_solved_question_ids.length + 1]
          test_questions << ncert_backed_question_ids
            .map { |qId| TestQuestion.new(:testId => topic_test.id, :questionId => qId, :seqNum => 1)}
        end

        topic_test.update(:sections => sections)
        TestQuestion.import! test_questions.flatten
      end
    end    
  end
end
