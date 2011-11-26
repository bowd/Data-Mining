require '~/Data-Mining/lib/setup.rb'

@db = DB.new('test')

def process(drug)
  terms = ([ drug['name'] ] + (drug['tradename'] || [])).map {|x| x.downcase }.uniq
  terms.each do |term|
    puts term
    term_search = Twitter::Search.new.containing(term).language('en').per_page(200)
    page_count = 0
    while true
      page_count += 1
      term_search.each do |tweet|
        tweet_hash = { 
          "tweet_id" => tweet.id,
          "text" => tweet.text,
          "user_id" => tweet.from_user_id,
          "search_term" => term
        }
        @db['tweets'].update({'tweet_id' => tweet.id}, tweet_hash, {:upsert => true})
      end
      
      if term_search.next_page? and page_count < 10
        term_search.fetch_next_page
      else
        break
      end
    end
  end
end


count = 0
@db['drugs'].find({}, {:sort => [ ['score', :desc] ]} ).each do |drug|
  processed = false
  while (!processed) 
    begin
      process(drug)
    rescue Exception => e
      sleep(1)
    else
      processed = true
    end
  end
end



