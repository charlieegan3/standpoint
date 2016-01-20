FROM rails:latest

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install --jobs 3 --retry 5

CMD bundle exec rails s -b 0.0.0.0 -p 3000
