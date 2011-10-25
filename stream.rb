require 'rubygems'
require 'tweetstream'
require 'mongo'

@conn = Mongo::Connection.new
@db   = @conn['test']
@coll = @db['tweets']

#TweetStream.configure do |config|
#  config.consumer_key = '7UAaYJecav2qpglDn788w'
#  config.consumer_secret = 'egZW4VsfR6hvE7gppI7n1QjALaP5JQceMWJvdspUg'
#  config.oauth_token = '46872625-f0sr2VhRsqfd8yfIywtyjG6MvRjB2vvr4NdNdE6XI'
#  config.oauth_token_secret = 'hTNn41NFHq9mFtNvhsHpriQpixeNwoptZGLkCTWqZ8'
#  config.auth_method = :oauth
#  config.parser   = :yajl
#end

TweetStream.configure do |config|
  config.username = 'dumi_mrr'
  config.password = 'jabberwocky'
  config.auth_method = :basic
  config.parser   = :yajl
end
# This will pull a sample of all tweets based on
# your Twitter account's Streaming API role.

TweetStream::Client.new.sample do |status|
  #The status object is a special Hash with
  #method access to its keys.
 puts "Mama are mere"
 @coll.insert({'text' => status.text})
end
