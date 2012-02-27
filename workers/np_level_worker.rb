require "bunny"
require 'yaml'
b = Bunny.new(:logging => false) 
b.start

q = b.queue("parsed_tweets")

msg = YAML::load(q.pop[:payload])

puts msg

b.stop
