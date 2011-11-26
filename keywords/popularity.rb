require 'open-uri'
require 'nokogiri'
require 'mongo'

def get_score(term)
  escaped_term = URI.escape(term+" ", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  doc = Nokogiri::HTML(open("http://www.bing.com/search?q="+escaped_term))
  Integer(doc.xpath('//span[@class="sb_count" and @id="count"]')[0].text.split(' ')[2].gsub(',', ''))
end

@conn = Mongo::Connection.new
@db   = @conn['test']
@coll = @db['drugs']

count = 0
@coll.find().each do |row|
  term = row['name']
  begin
    score1 = get_score(term)
    score2 = get_score("i use #{term}")
    score3 = get_score("#{term} medicine")
    score4 = get_score("#{term} drug")
    @coll.update(row, { "$set" => {:partial_scores => { :k1 => score1, :k2 => score2, :k3 => score3, :k4 => score4 }}})
    if row.has_key?("tradename")
      row["tradename"].each do |tradename|
        score1 = get_score(tradename)
        score2 = get_score("i use #{tradename}")
        score3 = get_score("#{tradename} medicine")
        score4 = get_score("#{tradename} drug")
        @coll.update(row, { "$set" => { "partial_scores.tradename.#{tradename}" => {:k1 => score1, :k2 => score2, :k3 => score3, :k4 => score4}}})
      end
    end

  rescue Exception => e
    puts e
    puts "Error on: #{term}"
  end
  count+=1
  puts "Done: #{count}" if (count%50) == 0
end 

 
