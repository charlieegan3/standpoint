FROM ruby:2.1

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY . /app

CMD ruby app.rb
