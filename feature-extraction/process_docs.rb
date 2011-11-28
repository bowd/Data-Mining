require '~/Data-Mining/lib/setup.rb'

word_map = {} 
doc_map = {}
wd_map = {}

def tokenize(doc) 
  doc.gsub(/[^[:alnum:]]/,' ').split(' ').map {|x| x.strip.downcase}  
end

count = 1
wc = 1
File.open('test', 'r').each_line do |doc|
  tokenize(doc).each do |w| 
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

File.open('vocab', 'w') do |f|
  word_map.each do |k, v|
    f.puts("#{k}")
  end
end

File.open('wd_map.tsv', 'w') do |f|
  wd_map.each do |w,docs|
    docs.each do |doc, count|
      f.puts("#{doc}\t#{w}\t#{count}")
    end
  end
end

