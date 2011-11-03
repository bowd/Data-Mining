require 'gscraper'

q = GScraper::Search.query(:query => 'aspirin')
puts q.number_of_result

