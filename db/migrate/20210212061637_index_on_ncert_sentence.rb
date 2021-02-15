class IndexOnNcertSentence < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE INDEX "ncert_sentence_idx" ON "NcertSentence"("sentence");'
  end
end
