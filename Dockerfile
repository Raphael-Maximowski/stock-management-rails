# syntax=docker/dockerfile:1

# Usar a mesma versão do Ruby
ARG RUBY_VERSION=3.4.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS development

# Rails app lives here
WORKDIR /rails

# Install packages para desenvolvimento (incluindo PostgreSQL client)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    build-essential \
    git \
    nodejs \
    libyaml-dev \       
    pkg-config \         
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT=""

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Create directory for pids and set permissions
RUN mkdir -p tmp/pids && \
    chmod -R 777 tmp log storage

# Expose port for development
EXPOSE 3000

# Entrypoint para desenvolvimento
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Start server in development mode
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]