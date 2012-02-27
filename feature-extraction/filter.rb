require '~/Data-Mining/lib/setup.rb'


module Filtering
  @@db = DB.new('test')
  def self.db
    @@db
  end
  class DrugNameFilter
    @@drugs = Filtering::db['drugs'].find().map {|drg| [drg['name'], drg['tradename']].flatten}.flatten.uniq
    
    def self.match(str) 
      @@drugs.includes?(str)
    end

    def self.updateQuery(str)
      { '$addToSet' => { 'drugs' => str } }
    end

    def self.nothingFound()
      { '$set' => {'drugs' => 0} }
    end

    def self.applied?(doc) 
      return doc.has_key?('drugs')  
    end
  end

  class Filter
    @@filters = [ DrugNameFilter ]
    
    def self.tokenize(doc) 
      doc.gsub(/[^[:alnum:]]/,' ').split(' ').map {|x| x.strip.downcase}  
    end

    def self.run()
      Filtering::db['tweets'].find({'drugs' => { '$exists' => false }}).each do |tweet|
        @@filters.each do |filter|
          at_least_once = false
          if !filter.applied?(tweet)
            tokenize(tweet['text']).each do |w|
              if filter.match(w)
                Filtering::db['tweets'].update(tweet, filter.updateQuery(w)) if filter.match(w)
                at_least_once = true
              end
            end
            if !at_least_once 
              Filtering::db['tweets'].update(tweet, filter.nothingFound())
            end
          end
        end
      end
      return "done"
    end
  end
end

ret = "pula"
while (ret != "done")
  begin 
    ret = Filtering::Filter.run()
  rescue Exception => e
  end 
end
