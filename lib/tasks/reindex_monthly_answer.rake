desc "Drop the existing monthly index on Answer.createdAt, create new one"

task :reindex_monthly_answer => :environment do 
  lower_date_limit = 1.months.ago.midnight

  ActiveRecord::Base.connection.execute("SET statement_timeout = '5min';")
  puts "Create new index for answers submitted on or after #{lower_date_limit}"
  ActiveRecord::Base.connection.execute("
    CREATE INDEX partial_idx_answer_created_at_1_month_tmp  ON 
    \"Answer\"(\"createdAt\") where \"Answer\".\"createdAt\"  >= '#{lower_date_limit}';
  ")

  puts "Drop existing index"
  ActiveRecord::Base.connection.execute("DROP INDEX partial_idx_answer_created_at_1_month;")
  ActiveRecord::Base.connection.execute("
    ALTER INDEX partial_idx_answer_created_at_1_month_tmp RENAME TO partial_idx_answer_created_at_1_month;
  ")
end
