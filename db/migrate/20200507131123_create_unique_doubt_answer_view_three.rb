class CreateUniqueDoubtAnswerViewThree < ActiveRecord::Migration[5.2]
  def change
    execute 'create view "public"."UniqueDoubtAnswer" as select * from (
      select d.*, row_number() over ( PARTITION by d."doubtId" order by d."id" ) from "DoubtAnswer" d inner join "Doubt" a on d."doubtId" = a.id where d."userId" in (select "userId" from "admin_users" where "role" = \'faculty\')
    ) "_event" where row_number = 1'
  end
end
