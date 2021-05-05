desc "Edit the questions in Question table so that options abcd are changed to 1234"

task :question_edit => :environment do 
  ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
  Question.where("type='MCQ-SO' AND question like '%(d)%'").each do |qs|
    qs.change_option_index!
  end
end
