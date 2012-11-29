require_relative "prelingerpane/version"
require_relative 'prelingerpane/prel_scrape'
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

  def self.display_metadata(doc, extension, output = STDOUT)
    output.puts "\n------------------------------------------------------\n"
    metadata_to_show.each do |metadata|
      output.puts "#{metadata.capitalize}: #{doc[metadata]}\n"
    end
    output.puts "URL: #{create_url(doc, extension)}"
  end

  def self.create_url(doc, extension)
    "http://archive.org/download/#{doc['identifier']}/#{doc['identifier']}#{extension}"
  end


  def self.best_format(available_formats)
    #puts "formats looks like: #{formats}"
    (preferred_formats & available_formats).first
  end

  def self.get_extension(format)
    extension_hash[format]
  end

  def self.run
    #search_path  = '/advancedsearch.php'
    search_token = %q{collection:"prelinger" } + self.title_keyword

    scraper = PrelScrape.new
    json    = JSON.parse(scraper.search_results(scraper.search_suffix, search_token))

    json['response']['docs'].each do |doc|
      this_best_format = self.best_format(doc['format'])
      extension        = self.get_extension(this_best_format)
      url              = self.create_url(doc, extension)
      self.display_metadata(doc, extension)
      self.download_video(doc, scraper, url, extension)

      puts "Extension is: #{extension}"
      puts "URL is: #{url}"
      puts "Best available format is: #{this_best_format}"
    end

    puts "Working..."
    begin
      @threads.each { |t| t.join }
    rescue NoMethodError
      puts "There were no results from that search."
    end
  end

  private
  def self.metadata_to_show
    %w{title description creator format}
  end

  def self.preferred_formats
    ["512Kb MPEG4", "Ogg Video", "MPEG2", "HiRes MPEG4", "Animated GIF", "Thumbnail"]
  end

  def self.extension_hash
    { "512Kb MPEG4" => '_512kb.mp4', "Ogg Video" => '_3mb.ogv', "MPEG2" => '.mpeg',
      "HiRes MPEG4" => '_edit.mp4', "Animated GIF" => '.gif',
      "Thumbnail"   => '.thumbs/*' }
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