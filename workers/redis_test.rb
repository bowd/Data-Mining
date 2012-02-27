require 'redis'

redis = Redis.new

redis.set "foo", "bar"

puts redis.get("foo")
