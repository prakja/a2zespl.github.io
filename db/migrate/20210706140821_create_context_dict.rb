class CreateContextDict < ActiveRecord::Migration[5.2]
  # we are using the following dictionary to remove stopwords without stemming 
  # any text, that way `ts_toquery` operations seems to be working better
  def up
    execute "CREATE TEXT SEARCH DICTIONARY context_dict (
      TEMPLATE = pg_catalog.simple,
      STOPWORDS = english
    );"

    execute "CREATE TEXT SEARCH CONFIGURATION context_dict (copy = english);"

    execute "ALTER TEXT SEARCH CONFIGURATION context_dict 
      ALTER MAPPING FOR asciihword, asciiword, hword, hword_asciipart, hword_part, word 
      WITH context_dict;"
  end

  def down
    execute "DROP TEXT SEARCH DICTIONARY context_dict;"
  end
end
