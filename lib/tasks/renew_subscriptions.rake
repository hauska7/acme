# frozen_string_literal: true

desc 'Renew subscriptions'
task renew_subscriptions: :environment do
  RenewSubscriptionsService.call
end
