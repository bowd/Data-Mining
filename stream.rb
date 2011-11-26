require 'rubygems'
require 'tweetstream'
require 'mongo'

@conn = Mongo::Connection.new
@db   = @conn['test']
@coll = @db['tweets2']

if ARGV[0] == 'oauth'
  puts "Connecting using oauth"
  TweetStream.configure do |config|
    config.consumer_key = 'mSSf6kbAmtAy34rK49F6Rg'
    config.consumer_secret = 'KKTcwftJyK2znMHNOPpRZFJQcMMLNaiDMzw0Yz5sN8'
    config.oauth_token = '404283083-5EfBQiO95yeZTiBNX93GM9177jea9pCERvHHmlVr'
    config.oauth_token_secret = 'Zyo3i4twu9Zj0Ai3iVYY7hPQuoLtHpP3FPXG59uG4'
    config.auth_method = :oauth
    config.parser   = :yajl
  end
else
  puts "Connection using basic" 
  TweetStream.configure do |config|
    config.username = 'dumitrb9'
    config.password = 'heLLismine1'
    config.auth_method = :basic
    config.parser   = :yajl
  end
end
# This will pull a sample of all tweets based on
# your Twitter account's Streaming API role.
count = 0
TweetStream::Client.new.track('ibuprofen', 'tylanol', 'orap', 'xanax', 
                              'ativan', 'paxil', 'ambien', 'nexium', 'oxycodone', 
                              'ciloxan', 'elavil', 'dexedrine')  do |status|
  #The status object is a special Hash with
  #method access to its keys.
  @coll.insert({'text' => status.text})
  count += 1
  puts count
end
