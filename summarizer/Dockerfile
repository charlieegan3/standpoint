FROM ruby

WORKDIR /app
ADD . /app

RUN gem install bundler
RUN bundle install

CMD /bin/bash
