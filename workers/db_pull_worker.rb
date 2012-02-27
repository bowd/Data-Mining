require '~/Data-Mining/lib/setup.rb'
require 'redis'
require 'bunny'
require 'ffi/hunspell'

@db = DB.new('test')
@redis = Redis.new
@bunny = Bunny.new(:logging => false)

if !@redis.hgetall("PULL_WORKER").empty?
  pw = @redis.hgetall("PULL_WORKER")
  puts "ERROR: A db pull worker is already active on #{pw["host"]} with PID: #{pw["pid"]}"
  exit 0
end

log = File.new(File.expand_path("~/Data-Mining/log/db_pull_worker-#{Time.now.to_i}.log"), 'w')

pw_host = ENV['HOSTNAME']
pw_pid = $$

@redis.hset("PULL_WORKER", "host", pw_host)
@redis.hset("PULL_WORKER", "pid", pw_pid)

log_write log, "Starting new session on #{pw_host} with PID #{pw_pid}"
log_write log, "Starting up bunny..."
@bunny.start
log_write log, "Bunny is up."

@queue = @bunny.queue("tweets")
@exchange = @bunny.exchange("")

@dict = FFI::Hunspell.divt('en_US')

def preprocess(text)
  # Remove unwanted chars from text
  ret = text.gsub(/[^[:alnum:] ,.;!?+&'\/]/, "").downcase
  ret = ret.gsub('\n', "").gsub('&quot;', ' ')
  puts ret
  "+&".split("").each {|c| ret = ret.gsub(c, " and ")}
  puts ret
  ret = ret.gsub("/", " or ")
  puts ret
  ret = ret.gsub(/((?<=[a-z]{2})(?=[0-9,.;?!])|(?<=[0-9,.;?!])(?=[a-z]{2}))/,' ')
  puts ret
  ret = ret.split(" ").map do |x|
    puts x
    x if ",.;!?".include? x
    begin
      return @dict.suggest(x).first if !@dict.check? x && !@dict.suggest(x).empty?
    rescue Exception => e
    end
    x
  end.join(" ")
end

begin
@db['tweets'].find({ 'search_term' => { "$in" => ['zoloft', 'xanax', 'vicodin', 'vyvanse', 'levothyroxine', 'ibuprofen', 'aspirin']}, 'spam' => 0, "$or" => [ { 'status' => 'IN_QUEUE' }, { 'status' => { '$exists' => false } } ] }).each do |doc|
  tweet_info = { :id => doc['tweet_id'], :text => preprocess(doc['text']) }
  msg = YAML::dump(tweet_info)
  @exchange.publish(msg, :key => 'tweets')
  @db['tweets'].update(doc, { '$set' => { 'status' => 'IN_QUEUE' } })
end
rescue Exception => e
  log_write log, "TERMINATING"
  log_write log, "Reason: #{e}"

  @redis.del "PULL_WORKER"
  @bunny.stop
  @dict.close
end

log_write log, "TERMINATING"
log_write log, "Reason: no more unprocessed tweets."

@redis.del "PULL_WORKER"
@bunny.stop
@dict.close
