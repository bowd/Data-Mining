require 'open-uri'
require 'nokogiri'
require 'gscraper'

medicine_file = File.open('./medications', 'r')
regex = Regexp.new(/(.*) \((.*)\)/)
term_hash = {}

medicine_file.each_line do |line|
  match = regex.match(line)
  term = 
    if match
      match[0].strip
    else 
      line.strip
    end

  if term_hash[term].nil?
    q = GScraper::Search.query(:query => term)
    term_hash[term] = q.number_of_results  
  end
  sleep(0.2)
end 

term_array = term_hash.to_a.sort {|a,b| b[1]<=>a[1]}
term_array.each {|(term, rank)| puts "#{rank} - #{term}"}
      


