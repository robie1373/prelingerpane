require_relative "prelingerpane/version"
require_relative 'prelingerpane/prel_scrape'
require_relative 'prelingerpane/player'
require_relative 'prelingerpane/saver'
require_relative 'prelingerpane/video_metadata'
require 'json'
require "highline/import"

module Prelingerpane
  OSX_SAVE_LOC = File.join(ENV['HOME'], "Movies", "PrelingerPane")
  RASPI_SAVE_LOC = File.join(ENV['HOME'], "mnt", "usb", "PrelingerPane")

  def self.title_keyword(input = $stdin, output = $stdout)
    console = HighLine.new(input, output)
    keyword = 'title:"Health: "'
    input = console.ask "Add a keyword to the search? (Press enter for default search.)"
    if input.match /\w+/
      keyword = %Q{title:"#{input}"}
    end
    keyword
  end

  def self.download_video(doc, scraper, url, extension, interactive)
    @threads = []
    name = "#{doc['identifier']}#{extension}"
    if interactive
      if agree("Download this video? (y/n)")
        @threads << Thread.new { scraper.video(url, name) }
      end
    else
      #@threads << Thread.new { scraper.video(url, name) }
    end
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
    (preferred_formats & available_formats).first
  end

  def self.get_extension(format)
    extension_hash[format]
  end

  def self.run(input = $stdin, output = $stdout, interactive = false, search_term = "")
    if interactive
      search_token = %q{collection:"prelinger" } + self.title_keyword(input, output)
    else
      search_term = search_term || ""
      search_token = %q{collection:"prelinger" } + search_term
    end

    scraper = PrelScrape.new
    json = JSON.parse(scraper.search_results(scraper.search_suffix, search_token))

    #result = Struct.new(:title, :description, :creator, :url)

    result_objects = []
    json['response']['docs'].each do |doc|
      this_best_format = self.best_format(doc['format'])
      extension = self.get_extension(this_best_format)
      url = self.create_url(doc, extension)
      self.display_metadata(doc, extension, output)
      self.download_video(doc, scraper, url, extension, interactive)


      this_result = VideoMetadata.new
      this_result.title = doc['title']
      this_result.description = doc['description']
      this_result.creator = doc['creator']
      this_result.url = url
      #output.puts "this_result has a title of #{this_result.title}\nand a URL of #{url}</br>"
      if interactive
        output.puts "Title is: #{this_result.title}"
        output.puts "URL is: #{this_result.url}"
        #output.puts "Best available format is: #{this_best_format}"
      end
      result_objects << this_result
    end

    output.puts "Working..."
    begin
      @threads.each { |t| t.join }
    rescue NoMethodError
      output.puts "There were no results from that search."
    end
    result_objects
  end

  private
  def self.metadata_to_show
    %w{title description creator format}
  end

  def self.preferred_formats
    ["512Kb MPEG4", "Ogg Video", "MPEG2", "HiRes MPEG4", "Animated GIF", "Thumbnail"]
  end

  def self.extension_hash
    {"512Kb MPEG4" => '_512kb.mp4', "Ogg Video" => '_3mb.ogv', "MPEG2" => '.mpeg',
     "HiRes MPEG4" => '_edit.mp4', "Animated GIF" => '.gif',
     "Thumbnail" => '.thumbs/*'}
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