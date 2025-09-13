#!/bin/bash
set -e

cd /workspaces/rails-interview

echo "Waiting for bundle install to complete..."
until [ -f /workspaces/rails-interview/Gemfile.lock ]; do
  echo "Waiting for Gemfile.lock..."
  sleep 2
done

if [ ! -d "vendor/bundle" ] && [ ! -f ".bundle/config" ]; then
  echo "Installing gems..."
  bundle install
fi

sleep 5

echo "Starting Sidekiq..."
exec bundle exec sidekiq