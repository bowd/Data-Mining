require '~/Data-Mining/lib/setup.rb'
require 'yaml'

@db = DB.new "test"
@semtypes_map = {}

def load_semtypes
  sem_class = ""
  sem_subclass = ""
  File.open("filtered_semtypes.txt", "r").each_line do |line|
    if line.start_with? "{" 
      sem_class = line.strip.gsub(/{|}/, "")
      sem_subclass = ""
      next
    end
    if line.start_with? "["
      sem_subclass = line.strip.gsub(/\[|\]/, "")
      next
    end
    head = sem_class + (sem_subclass != "" ? ">#{sem_subclass}" : "") + ">"
    (code, title) = line.strip.split("|")
    @semtypes_map[code] = head+title
  end
end

load_semtypes

@db['chunk_sets'].find({'$or' => [ {'consolidated' => { '$exists' => false } }, { 'consolidate' => false } ] }).each do |chunk_set|
  chunks = {}
  mappings = {}
  chunk_set['chunks'].each do |chunk|
    chunks[ chunk['id'].to_s ] = chunk['text']
  end
  puts chunks
  chunk_set['semtypes'].each do |semmapping|
    semmapping['semtypes'].each do |semtype|
      if @semtypes_map.has_key?(semtype)
        write_in = mappings
        @semtypes_map[semtype].split(">").each do |key|
          write_in[key] = (key.downcase == key ? {} : []) if !write_in.has_key? key
          write_in = write_in[key]
        end
        write_in = [] if write_in == {}
        write_in << chunks[ semmapping['id'].to_s ]
      end
    end
  end
  tweet = @db['tweets'].find_one({'tweet_id' => chunk_set['tweet_id']})
  puts mappings
  @db['parsed_tweets_test'].insert({'tweet_id' => chunk_set['tweet_id'], 'text' => tweet['text'], 'mappings' => mappings})
  
end
