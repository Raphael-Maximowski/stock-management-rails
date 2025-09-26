#!/bin/bash
set -e

echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -q; do
  sleep 1
done

echo "PostgreSQL is ready!"

# REMOVER arquivo server.pid se existir (IMPORTANTE!)
if [ -f tmp/pids/server.pid ]; then
  echo "Removing existing server.pid file..."
  rm -f tmp/pids/server.pid
fi

echo "Setting up database..."
# Verificar se o banco já existe antes de criar
if ! bundle exec rails db:version > /dev/null 2>&1; then
  echo "Creating database..."
  bundle exec rails db:create
fi

echo "Running migrations..."
bundle exec rails db:migrate

echo "Starting Rails server..."
exec "$@"