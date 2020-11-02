FROM ruby
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client yarn
RUN mkdir /heliotrope
WORKDIR /heliotrope
COPY Gemfile /heliotrope/Gemfile
COPY Gemfile.lock /heliotrope/Gemfile.lock
COPY package.json /heliotrope/package.json
COPY yarn.lock /heliotrope/yarn.lock
RUN gem install bundler -v '2.0.2'
RUN bundle install
RUN yarn install --check-files
COPY .. /heliotrope
EXPOSE 3000

#CMD ["rails", "server", "-b", "0.0.0.0"]