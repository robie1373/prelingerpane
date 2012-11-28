require "prelingerpane/version"
require 'prelingerpane/prel_scrape'
require 'json'
require "highline/import"

module Prelingerpane
  def self.title_keyword
    keyword = 'title:"Health: "'
    input   = ask "Add a keyword to the search? (Press enter for default search.)"
    if input.match /\w+/
      keyword = %Q{title:"#{input}"}
    end
    keyword
  end

  def self.download_video(doc, scraper, url, extension)
    @threads = []
    name     = "#{doc['identifier']}#{extension}"
    @threads << Thread.new { scraper.video(url, name) } if agree("Download this video? (y/n)")
  end

  def self.stream_video(doc, url)
    # TODO write streaming code that the raspberry pi can use
  end

  def self.display_metadata(doc, extension)
    puts "\n------------------------------------------------------\n"
    %w{title description creator format}.each do |metadata|
      puts "#{metadata.capitalize}: #{doc[metadata]}\n"
    end
    puts "URL: #{create_url(doc, extension)}"
  end

  def self.create_url(doc, extension)
    "http://archive.org/download/#{doc['identifier']}/#{doc['identifier']}#{extension}"
  end

  def self.best_format(doc)
    formats = ["512Kb MPEG4", "Ogg Video", "MPEG2", "HiRes MPEG4", "Animated GIF", "Thumbnail"]
    (formats & doc['format']).first
  end

  def self.get_extension(format)
    { "512Kb MPEG4" => '_512kb.mp4', "Ogg Video" => '_3mb.ogv', "MPEG2" => '.mpeg',
      "HiRes MPEG4" => '_edit.mp4', "Animated GIF" => '.gif',
      "Thumbnail"   => '.thumbs/*' }[format]
  end

  def self.run
    search_path  = '/advancedsearch.php'
    search_token = %q{collection:"prelinger" } + self.title_keyword

    scraper = PrelScrape.new
    json    = JSON.parse(scraper.search_results(search_path, search_token))

    json['response']['docs'].each do |doc|
      best_format = self.best_format(doc)
      puts "Best format is: #{best_format}"

      extension = self.get_extension(best_format)
      puts "Extension is: #{extension}"

      file_name = self.create_url(doc, extension)
      puts "Filename is: #{file_name}"

      self.display_metadata(doc, extension)
      puts "Best available format is: #{self.best_format(doc)}"
      self.download_video(doc, scraper, file_name, extension)
    end

    puts "Working..."
    @threads.each { |t| t.join }
  end
end

=begin
{"mediatype"=>"movies",
 "publicdate"=>"2002-07-16T00:00:00Z",
 "description"=>"How exercise will make you healthy and popular.",
 "date"=>"1948-11-30T00:00:00Z",
 "licenseurl"=>"http://creativecommons.org/licenses/publicdomain/",
 "title"=>"Exercise and Health",
 "type"=>"MovingImage",
 "downloads"=>534475,
 "week"=>47,
 "month"=>240,
 "num_reviews"=>3,
 "avg_rating"=>4.0,
 "identifier"=>"Exercise1949",
 "subject"=>["Health and hygiene", "Exercise"],
 "format"=>["256Kb Real Media", "512Kb MPEG4", "64Kb Real Media", "Animated GIF", "Archive BitTorrent", "Cinepack", "HiRes MPEG4", "MPEG2", "Metadata", "Ogg Video", "Thumbnail"],
 "collection"=>["prelinger"],
 "creator"=>["Coronet Instructional Films"],
 "score"=>8.997265}
=end