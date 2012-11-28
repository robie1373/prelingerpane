require "prelingerpane/version"
require 'prelingerpane/prel_scrape'
require 'json'

module Prelingerpane
  scraper = PrelScrape.new
  json = JSON.parse(scraper.body('/advancedsearch.php', 'collection:"prelinger" title:"Health: "'))
  json['response'].each_pair do |key, value|
    puts "#{key} ---> #{value}\n\n"
  end
end
