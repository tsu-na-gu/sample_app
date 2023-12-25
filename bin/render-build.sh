#! /usr/bin/env bash
# exit on error
bundle install
bundle exec rails assert:precompile
bundle exec rails asserts:clean
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 budle exec rails db:migrate:reset
bundle exec rails db:seed