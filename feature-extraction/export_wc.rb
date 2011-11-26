require "~/Data-Mining/lib/setup.rb"

@db = DB.new('test')

word_map = {}
doc_map = {}
wd_map = {} 

def tokenize(doc) 
  doc.gsub(/[^[:alnum:]]/,' ').split(' ').map {|x| x.strip.downcase}  
end

count = 1
wc = 1
@db['tweets'].find({'search_term' =>  'ibuprofen'}).each do |doc|
  doc_map[count] = doc['tweet_id'].to_s
  tokenize(doc['text']).each do |w| 
    if !word_map.has_key?(w)
      word_map[w] = wc
      wc += 1
    end
    wd_map[word_map[w]] = {} if !wd_map.has_key?(word_map[w])
    wd_map[word_map[w]][count] =
      if wd_map[word_map[w]].has_key?(count)
        wd_map[word_map[w]][count] + 1
      else
        1
      end
  end
  count += 1
end

File.open('doc_map.tsv', 'w') do |f|
  doc_map.each do |k, v|
    f.puts("#{k}\t#{v}") 
  end
end

File.open('word_map.tsv', 'w') do |f|
  word_map.each do |k, v|
    f.puts("#{k}\t#{v}")
  end
end

File.open('wd_map.tsv', 'w') do |f|
  wd_map.each do |w,docs|
    docs.each do |doc, count|
      f.puts("#{doc}\t#{w}\t#{count}")
    end
  end
end
