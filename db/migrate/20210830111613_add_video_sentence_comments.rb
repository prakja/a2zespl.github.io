class AddVideoSentenceComments < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TABLE "QuestionNcertSentence" ADD COLUMN comment VARCHAR;
    SQL

    execute <<-SQL
      ALTER TABLE "QuestionVideoSentence" ADD COLUMN comment VARCHAR;
    SQL
  end

  def down
    execute <<-SQL
    ALTER TABLE "QuestionNcertSentence" DROP COLUMN comment;
    SQL

    execute <<-SQL
      ALTER TABLE "QuestionVideoSentence" DROP COLUMN comment;
    SQL
  end
end
