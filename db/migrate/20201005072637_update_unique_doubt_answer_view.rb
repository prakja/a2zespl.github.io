class UpdateUniqueDoubtAnswerView < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      drop view if exists "public"."UniqueDoubtAnswer"
    SQL

    execute 'create view "public"."UniqueDoubtAnswer" as select * from (
      select d.*, row_number() over ( PARTITION by d."doubtId" order by d."id" ) from "DoubtAnswer" d inner join "Doubt" a on d."doubtId" = a.id where d."userId" in (select "userId" from "admin_users" where "role" = \'faculty\' or "role" = \'superfaculty\')
    ) "_event" where row_number = 1'
  end
end
