# Assignment

https://www.fakepay.io/challenge

This solution contains the regular assignment and one bonus task of a worker for subsequent subscription charges

# Setup project

add master key:
- create file /config/master.key
- add file content: 9ea80b176970ef5004413cf81ab678db
- note: master key should not be commited to repository normally

docker-compose create

docker-compose start

bundle install

rake db:create && rake db:migrate

rails s

# Run tests

rspec

# Run bonus renew subscriptions worker

rake renew_subscriptions

# Thoughts on this project

Currently we use the same fakepay api key for testing and "production" there would need to be a separate one for testing.

There is still a few rubocop errors that should be fixed. They are leftover from generating project.

There is a vcr error when running rspec it is probably related to ruby/rails version. Please inspect the patch here: config/initializers/001_vcr_patch.rb

Signup model should probably be renamed to Subscription


