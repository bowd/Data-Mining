require 'nokogiri'
require 'open-uri'

url = "http://www.medicinenet.com/medications/alpha_"


('a'..'z').each do |l|
  doc = Nokogiri::HTML(open(url+l+".htm"))
  doc.xpath('//div[@class="AZ_results"]/ul/li/a').each {|node| puts node.text}
end
