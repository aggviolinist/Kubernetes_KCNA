FROM ruby:3.4.1

WORKDIR /code
COPY . /code
RUN bundle install

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]