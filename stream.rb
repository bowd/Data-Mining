require 'rubygems'
require 'tweetstream'


puts "Starting"
TweetStream.configure do |config|
  config.username = 'dumi_mrr'
  config.password = 'jabberwocky'
  config.auth_method = :basic
  config.parser   = :yajl
end
# This will pull a sample of all tweets based on
# your Twitter account's Streaming API role.
TweetStream::Client.new.sample do |status|
  # The status object is a special Hash with
  puts "Mama"  
  # method access to its keys.
  puts "#{status.text}"
end
