desc "Edit the questions in Question table so that options abcd are changed to 1234"

task :question_edit => :environment do 
  ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
  Question.where("type='MCQ-SO' AND question like '%(d)%'").each do |qs|
    if(!((qs.question=~/.*?\s*.*?\(a\).*?\s*.*?\(b\).*?\s*.*?\(c\).*?\s*.*?\(d\).*/).nil?) && (qs.question=~/.*?\s*.*?1\..*?\s*.*?2\..*?\s*.*?3\..*?\s*.*?4\..*/).nil?)  
      qs.question.gsub!('(a)', '1.')
      qs.question.gsub!('(b)', '2.')
      qs.question.gsub!('(c)', '3.')
      qs.question.gsub!('(d)', '4.')
    #  p qs.question
      qs.save!
    end
  end
end