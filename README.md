# README

## Assignment

https://www.fakepay.io/challenge

This solution contains the regular assignment and one bonus task of a worker for subsequent subscription charges

## Setup project

add master key:
- create file /config/master.key
- add file content: 9ea80b176970ef5004413cf81ab678db
- note: master key should not be commited to repository normally

docker-compose create

docker-compose start

use ruby-3.1.0

bundle install

rake db:create && rake db:migrate

rails s

## Run tests

rspec

## Usage

### Correct subscription signup

```
curl -X POST \
  -H 'Content-Type: application/json' \
  -d '{"name":"Johny Bravo","plan":"bronze_box","shipping_address":{"street":"Sesame Street","city":"New York","zip_code":"11111","country":"USA"},"billing":{"card_number":"4242424242424242","cvv":"123","expiration_month":"02","expiration_year":2024,"zip_code":"22222"}}' \
  localhost:3000/api/v1/subscriptions
```

### Failing Acme validation

```
curl -X POST \
  -H 'Content-Type: application/json' \
  -d '{}' \
  localhost:3000/api/v1/subscriptions
```

### Failing Fakepay validation

```
curl -X POST \
  -H 'Content-Type: application/json' \
  -d '{"name":"Johny Bravo","plan":"bronze_box","shipping_address":{"street":"Sesame Street","city":"New York","zip_code":"11111","country":"USA"},"billing":{"card_number":"4242424242424241","cvv":"123","expiration_month":"02","expiration_year":2024,"zip_code":"22222"}}' \
  localhost:3000/api/v1/subscriptions
```

## Run bonus renew subscriptions worker

rake renew_subscriptions

## Thoughts on this project

There is a vcr error when running rspec it is probably related to ruby/rails version. Please inspect the patch here: config/initializers/001_vcr_patch.rb

What I really like is that api responds with errors containing invalid fields corresponding to fields that were sent. Which should make it really easy for frontend developers to match error messages to invalid fields.

Best thing about renew subscription worker is that it can be run in parallel and there is no danger of charging twice for a subscription renewal. Also in case it crashes it can be just restarted there is no locked subscription records.

### Some improvements on current solution would be to:

- add a payment model that would store information about payments eg if succeeded or failed.
- add authorization
- introduce asynchronus payments on signup
