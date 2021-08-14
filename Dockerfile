FROM ruby:2.6.5

RUN apt update
RUN apt install -y nodejs
RUN cd /root
RUN mkdir np-admin
COPY . /root/np-admin/
# RUN ls /root/np-admin/
WORKDIR /root/np-admin/
RUN gem install bundler

RUN bundle config set without 'test'
RUN bundle config set git.allow_insecure true

ENV RAILS_ENV development
ENV RACK_ENV development
ENV RAILS_ROOT /root/np-admin/
ENV RAILS_SERVE_STATIC_FILES 1

RUN bundle install -j "$(getconf _NPROCESSORS_ONLN)" --retry 5 
EXPOSE 3000
# CMD ["rails", "server", "-p", "3004"]
# ENTRYPOINT ["./entrypoints/./docker-entrypoint.sh"]
CMD bundle exec puma -C config/puma.rb
