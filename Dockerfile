FROM nginx:alpine

LABEL description="Hosts the OpenProject documentation."
LABEL maintainer="operations@openproject.com"

ARG DOCS_PATH=/tmp/build/docs

RUN apk add --update \
    curl ruby ruby-dev ruby-json ruby-etc git \
    libc-dev pkgconfig libxml2-dev zlib-dev libxslt-dev \
    npm build-base python \
    && rm -rf /var/cache/apk/* \
    && gem install --no-document bundler pkg-config

RUN mkdir /tmp/build

WORKDIR $DOCS_PATH
# Install dependencies first so that code changes don't invalidate the cache.
COPY package.json package-lock.json $DOCS_PATH/
RUN npm install
# we do bundle and npm install in separate steps so not both has to be rebuild
# if just one has changed
COPY Gemfile Gemfile.lock $DOCS_PATH/
# For some reason this is necessary otherwise bigdecimal won't be available
# in alpine's ruby. Similarly we have to install ruby-json and ruby-etc earlier.
RUN echo "gem 'bigdecimal'" >> Gemfile
# Pry is not actually necessary but leaving it in the Gemfile makes the build
# fail due to missing dependencies in alpine.
RUN cat Gemfile | grep -v pry > Gemfile.new && rm Gemfile && cp Gemfile.new Gemfile
RUN bundle install && cp Gemfile.lock Gemfile.lock.new

WORKDIR /tmp/build

ARG CORE_ORIGIN="https://github.com/opf/openproject"
# Never provide a default ARG for the branch to ensure we always specify it
ARG CORE_REF
ENV OPENPROJECT_CORE=/tmp/build/core

echo "Cloning from $CORE_ORIGIN branch $CORE_REF"
RUN git clone $CORE_ORIGIN --branch $CORE_REF --depth 1 core

WORKDIR $DOCS_PATH
COPY . $DOCS_PATH/
# restore new Gemfile and Gemfile.lock (overriden due to COPY)
RUN cp Gemfile.new Gemfile && cp Gemfile.lock.new Gemfile.lock

RUN export SITE_URL="http://mywebsite.com" && bundle exec rake build && bundle exec middleman build --clean

RUN rm -rf /usr/share/nginx/html && mv build /usr/share/nginx/html

COPY ./docker /docker
ENTRYPOINT ["/docker/entrypoint.sh"]
