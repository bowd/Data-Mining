require 'wikipedia'
require 'json'
require 'mongo'

@conn = Mongo::Connection.new
@db   = @conn['test']
@coll = @db['drugs']

count = 0
@coll.find().each do |row|
  term = row['name']
  begin
    page = Wikipedia.find(term);
    result = JSON.parse(page.json)
    info = result["query"]["pages"].first[1]["revisions"].first["*"]

    info.split('|').each do |x|
      line = x.strip
      (a, b) = line.split(" = ")
      if (a == "tradename")
        @coll.update({:name => term}, {'$set' => {'tradename' => b.split(',').map{|x| x.strip} }})
      end
    end
  rescue Exception => e
    puts "Error on term: #{term}"
    puts e
  end
  count += 1
  puts "Done: #{count}" if (count%50) == 0
end
