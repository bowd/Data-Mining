require '~/Data-Mining/lib/setup.rb'

@db = DB.new('test')

count = 0
@db['drugs'].find({}, {:limit => 1200, :skip => 371, :sort => [ ['score', :desc] ] } ).each do |drug|
  count += 1
  puts count if drug['name'] == 'adderall'
end



