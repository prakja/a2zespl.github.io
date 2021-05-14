desc "Edit the questions in Question table so that options abcd are changed to 1234"

task :question_edit => :environment do 
  ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
  Question.neetprep_course.abcd_options.limit(100).each do |qs|
    ques = Nokogiri::HTML(qs.question);
    qs.convert_num_options
    ques_1 = Nokogiri::HTML(qs.question);
    if ques_1.text != ques.text
      p "https://admin1.neetprep.com/admin/questions/" + qs.id.to_s
      p ques.text
      p ques_1.text
      puts "\n Is this what you want to happen? [Y/N]"
      answer = STDIN.gets.chomp
      if answer == "Y"
        qs.change_option_index!
      elsif answer == "N"
      end
    end
  end
end
