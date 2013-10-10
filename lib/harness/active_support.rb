require "harness/active_support/version"

require 'harness'

events = %w(cache_read cache_generate cache_fetch_hit cache_write cache_delete)

events.each do |name|
  ActiveSupport::Notifications.subscribe "#{name}.active_support" do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Harness.timing "active_support.#{name}", event.duration
  end
end

ActiveSupport::Notifications.subscribe "cache_read.active_support" do |*args|
  payload = args.last
  next if payload[:super_operation] == :fetch

  if payload[:hit]
    Harness.increment 'cache.hit'
  else
    Harness.increment 'cache.miss'
  end
end

ActiveSupport::Notifications.subscribe "cache_fetch_hit.active_support" do |*args|
  Harness.increment 'cache.hit'
end

ActiveSupport::Notifications.subscribe "cache_generate.active_support" do |*args|
  Harness.increment 'cache.miss'
end
