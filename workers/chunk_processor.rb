require '~/Data-Mining/lib/setup.rb'
require 'yaml'

@db = DB.new 'test'

@db['chunk_sets'].find({}, {:limit => 1}).each do |chunk_set|
  relations = YAML::load(chunk_set['relations'])
  chunks = YAML::load(chunk_set['chunks'])
  puts relations
  puts chunks
end
