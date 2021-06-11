class AddPartialIndexAnswerCreatedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction! # need to disable transaction, since concurrently indexing does not support it

  def up
    execute "SET statement_timeout = '5min';"

    lower_date_limit = 1.months.ago.midnight
    execute "
      CREATE INDEX CONCURRENTLY partial_idx_answer_created_at_1_month  ON \"Answer\"(\"createdAt\") 
      where \"Answer\".\"createdAt\"  >= '#{lower_date_limit}';"
  end

  def down
    execute "DROP INDEX partial_idx_answer_created_at_1_month;"
  end
end
