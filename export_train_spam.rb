require '~/Data-Mining/lib/setup.rb'

@db = DB.new('test')

@db['tweets'].find({ 'spam' => 1}).each do |tweet|
  puts "{\"label\": #{tweet['spam']}, \"text\": \"#{tweet['text'].gsub(/\n|\r/, ' ')}\"}"
end

@db['tweets'].find({ 'spam' => 0}, {:limit => 100}).each do |tweet|
  puts "{\"label\": #{tweet['spam']}, \"text\": \"#{tweet['text'].gsub(/\n|\r/, ' ')}\"}"
end

