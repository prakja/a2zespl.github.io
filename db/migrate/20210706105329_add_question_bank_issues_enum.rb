class AddQuestionBankIssuesEnum < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute "ALTER TYPE \"enum_Doubt_doubtType\" ADD VALUE 'Wrong_Ncert_Sentence_Marking' ;"
    execute "ALTER TYPE \"enum_Doubt_doubtType\" ADD VALUE 'Wrong_Video_Sentence_Marking' ;"
  end

  def down
    execute "
    DELETE FROM pg_enum WHERE enumlabel IN('Wrong_Ncert_Sentence_Marking', 'Wrong_Video_Sentence_Marking) 
    AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'enum_Doubt_doubtType');"
  end
end
