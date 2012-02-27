require '~/Data-Mining/lib/setup.rb'

@db = DB.new('test')

def cleanify(text)
  text.gsub(/[^[:alnum:]]/,' ').split(' ').map {|x| x.strip}.join(' ')
end

done = false 
while !done
  done = true
  begin
    @db['tweets'].find({"spam" => { "$exists" => false }}).each do |twt|
      done = false
      spam = if cleanify(twt['text']).include? 'http'
              1
            else
              0
            end
      @db['tweets'].update(twt, { "$set" => { "spam" => spam } })
    end
  rescue Exception => e
  end
end


