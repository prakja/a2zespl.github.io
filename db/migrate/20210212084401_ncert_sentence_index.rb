class NcertSentenceIndex < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE INDEX "ncert_sentence_gin_idx" ON "NcertSentence" USING GIN (to_tsvector(\'english\', "sentence"));'
  end
end
