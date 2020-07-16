# README

This README would normally document whatever steps are necessary to get the
application up and running.

https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-18-04

Things you may want to cover:

* Ruby version

2.6.3

* Deployment instructions

Exclude .rail-version, .git, .gitignore

bundle update
gem update

rails g model out_table_name
rails g active_admin:resource model_name

### run on port 5000 else remove -b
rails s -b 5000 

### create view 
create view "topic_questions" as select "topicId" as "topic_id", "assetId" as "question_id" from "TopicAsset" where "deleted" = false and "assetType" = 'Question'

### Deploy

docker build -t registry.gitlab.com/learner.in/neetprepadmin .

docker push registry.gitlab.com/learner.in/neetprepadmin

kubectl apply -f dev-admin-service.yaml (optional)

kubectl apply -f dev-admin-deployment.yaml