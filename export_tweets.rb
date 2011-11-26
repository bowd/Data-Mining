require '~/Data-Mining/lib/setup.rb'
require 'builder'

@db = DB.new('test')


puts '<?xml version="1.0" encoding="UTF-8" ?>'
puts '<tweets>'
@db['tweets'].find().each do |twt|
  puts "  <tweet id=\"#{twt['tweet_id']}\" user_id=\"#{twt['user_id']}\">"
  puts "    #{twt['text']}"
  puts "  </tweet>"
end
puts '</tweets>'



