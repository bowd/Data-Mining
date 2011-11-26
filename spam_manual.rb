require '~/Data-Mining/lib/setup.rb'

@db = DB.new('test')

@db['tweets'].find({'search_term' => 'viagra', 'spam' => {'$exists' => false}}, {:limit => 200}).each do |tweet|
  puts "Is '#{tweet['text']}' spam? "
  spam = gets.chomp
  @db['tweets'].update(tweet, { "$set" => { "spam" => (spam == 'y' ? 1 : 0) } })
end

