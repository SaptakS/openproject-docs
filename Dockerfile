FROM nginx:alpine

LABEL description="Hosts the OpenProject documentation."
LABEL maintainer="operations@openproject.com"

ARG DOCS_PATH=/tmp/build/docs

RUN apk add --update \
    curl ruby ruby-dev ruby-json ruby-etc git \
    libc-dev pkgconfig libxml2-dev zlib-dev libxslt-dev \
    npm build-base python3 \
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
# Whether to index robots
ARG robots_allowed
ENV ROBOTS_ALLOWED=$robots_allowed
# Never provide a default ARG for the branch to ensure we always specify it
ARG core_ref
ENV CORE_REF=$core_ref
ARG core_branch
ENV CORE_BRANCH=$core_branch
# Never provide defaults for GTM and HUBSPOT and MATOMO
ARG gtm_tag
ENV GTM_ID=$gtm_tag
ARG hubspot_tag
ENV HUBSPOT_PORTAL_ID=$hubspot_tag
ARG matomo_enabled=false
ENV MATOMO_ENABLED=$matomo_enabled

RUN echo "GTM TAG IS SET TO $GTM_TAG, HUBSPOT TAG to $HUBSPOT_TAG, MATOMO ENABLED $MATOMO_ENABLED"

ENV OPENPROJECT_CORE=/tmp/build/core
# Disable Ruby warnings while many still spit 2.7 deprecation warnings
ENV RUBYOPT="-W0"

RUN echo "Cloning from $CORE_ORIGIN and resetting to $CORE_REF"
RUN git clone $CORE_ORIGIN core && cd core && git reset --hard $CORE_REF

WORKDIR $DOCS_PATH
COPY . $DOCS_PATH/
# restore new Gemfile and Gemfile.lock (overriden due to COPY)
RUN cp Gemfile.new Gemfile && cp Gemfile.lock.new Gemfile.lock

RUN export SITE_URL="http://mywebsite.com" && bundle exec rake build && bundle exec middleman build --clean

RUN echo "BUILDINFO" && cat data/buildinfo.yml
RUN echo "BUILDINFO ON PAGE" && cat build/index.html | grep 'Build '

RUN rm -rf /usr/share/nginx/html && mv build /usr/share/nginx/html

COPY ./docker /docker
ENTRYPOINT ["/docker/entrypoint.sh"]
