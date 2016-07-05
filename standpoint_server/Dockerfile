FROM rails:latest

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install

CMD bundle exec rake assets:precompile && bundle exec rails s -e production -b 0.0.0.0 -p 3000
