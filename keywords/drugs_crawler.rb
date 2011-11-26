require 'nokogiri'
require 'open-uri'



class DrugsCrawler
  @@base_url = "http://www.drugs.com"
  @@page_url_format = '%s/alpha/%s%d.html'
  
  @@number_of_pages_path = '//div[@class="pagingResults pagingResultsWithTitle clearAfter"]/p/a'
  @@popular_drugs_path = '//div[@class="boxList boxListPopular clearAfter"/div/a'
  @@drugs_path = '//ul[@class="drugTypeList"]/li/a'

  @@db = DB.new('test2', 'drugs')

  def self.run
    ('a'..'z').each do |letter|
      self.get_popular_drugs(letter)
      (1..self.get_number_of_pages(letter)).each do |page|
        page = Nokogiri::HTML(open(@@page_url_format % [ @@base_url, letter, page ]))
        page.xpath(@@drugs_path).each do |node|
          @@db.collection.update({:name => node.text.strip.downcase}, {}, {:upsert => true})
        end
      end 
    end
  end  

  def self.get_number_of_pages(letter)
    page = Nokogiri::HTML(open(@@page_url_format % [ @@base_url, letter, 1 ]))
    return Integer(page.xpath(@@number_of_pages_path).last.text)
  end

  def self.get_popular_drugs(letter)
    page = Nokogiri::HTML(open(@@page_url_format % [ @@base_url, letter, 1 ]))
    page.xpath(@@popular_drugs_path).each do |node|
      @@db.collection.insert({:name => node.text.strip.downcase, :popular => 1})
    end
  end
end
