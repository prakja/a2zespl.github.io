class NcertSentenceDetail < ApplicationRecord
  self.table_name = "NcertSentenceDetail"
  self.primary_key = "id"
  belongs_to :ncertSentence, foreign_key: "ncertSentenceId", class_name: 'NcertSentence'
end

