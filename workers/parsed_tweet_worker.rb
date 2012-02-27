require '~/Data-Mining/lib/setup.rb'
require 'redis'
require 'bunny'
require 'yaml'

@db = DB.new('test')
@redis = Redis.new
@bunny = Bunny.new(:logging => false)

pw_id = 0
pw_host = ENV['HOSTNAME']
pw_pid = $$

# @redis.hset("PULL_WORKER", "host", pw_host)
# @redis.hset("PULL_WORKER", "pid", pw_pid)

# log_write log, "Starting new session on #{pw_host} with PID #{pw_pid}"
# log_write log, "Starting up bunny..."
@bunny.start
# log_write log, "Bunny is up."

@queue = @bunny.queue("parsed_tweets")
# @exchange = @bunny.exchange("tweets_exchange")

#begin


ret = @queue.subscribe(:timeout => 30) do |msg|
  data = YAML::load(msg[:payload])
  parse_tree = TreeParser.new(data[":text"])
  chunks = parse_tree.chunks
  r_chunks = []
  chunks.each do |chunk|
    if r_chunks.select {|c| c[:text] == chunk["text"]}.empty?
      r_chunks << chunk
    end
  end
  @db["chunk_sets"].insert( { "tweet_id" => data[":id"], 
                              "relations" => YAML::dump(parse_tree.parent_of),
                              "chunks" => YAML::dump(r_chunks),
                              "nchunks" => r_chunks.size } )
end

puts ret.to_s

#rescue Exception => e
#  puts e.to_s
# log_write log, "TERMINATING"
# log_write log, "Reason: #{e}"

# @redis.del "PULL_WORKER"
#  @bunny.stop
#end

# log_write log, "TERMINATING"
# log_write log, "Reason: no more unprocessed tweets."

# @redis.del "PULL_WORKER"
@bunny.stop
