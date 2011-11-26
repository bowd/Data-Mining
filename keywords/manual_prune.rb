require '~/Data-Mining/lib/setup.rb'

@db = DB.new('test')

count = 0
@db['drugs'].find({}, {:limit => 1000, :sort => [ ['score', :desc] ]}).each do |drug|
  count += 1
  puts "(#{count}) Is #{drug['name']} viable? "
  answer = gets.chomp
  @db['drugs'].remove(drug) if answer == 'n'
end
