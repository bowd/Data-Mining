require 'rubygems'
require 'mongo'
require 'twitter'
require 'nokogiri'
require 'open-uri'
require 'date'

ROOT = File.dirname(File.expand_path(File.dirname(__FILE__)))

def require_dir(path_to_dir) 
  Dir.foreach(path_to_dir) do |item|
    next if item == '.' or item == '..' or item == __FILE__
    item_path = "#{path_to_dir}/#{item}"
    require item_path if File.file?(item_path) 
    require_dir(item_path) if File.directory?(item_path)
  end
end

require_dir("#{ROOT}/lib")

Twitter.configure do |config|
  config.consumer_key = "mSSf6kbAmtAy34rK49F6Rg"
  config.consumer_secret = "KKTcwftJyK2znMHNOPpRZFJQcMMLNaiDMzw0Yz5sN8"
  config.oauth_token = "404283083-5EfBQiO95yeZTiBNX93GM9177jea9pCERvHHmlVr"
  config.oauth_token_secret = "Zyo3i4twu9Zj0Ai3iVYY7hPQuoLtHpP3FPXG59uG4"
end



