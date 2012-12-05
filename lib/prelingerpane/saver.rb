require 'uri'

module Prelingerpane
  class VideoSaver
    def initialize(to_save, scraper)
      @to_save = to_save
      @scraper = scraper
      #@url = url
    end

    def save_files
      to_save.each do |choice|
        puts "\n#{'-'*20}Saving #{url_to_filename(choice.url)}\n#{'-'*20}"
        save(choice.url, url_to_filename(choice.url))
        puts "\n#{'-'*20}Done saving #{url_to_filename(choice.url)}\n#{'-'*20}"
      end
    end

    def name
      url_to_filename to_save
    end

    private
    def save(url, name)
      if File.directory?(save_location)
        #puts ("URl ---> #{url}")
        #puts ("name ---> #{name}")
        #puts ("save_location ---> #{save_location}")
        @scraper.video(url, name, save_location)
      else
        puts "making Directory #{save_location}"
        FileUtils.mkdir_p save_location
        #puts ("URl ---> #{url}")
        #puts ("name ---> #{name}")
        #puts ("save_location ---> #{save_location}")
        @scraper.video(url, name, save_location)
      end
    end

    def save_location
      loc = File.join(ENV['HOME'], "Movies", "PrelingerPane") if RUBY_PLATFORM =~ /(darwin)/i
      loc = File.join(ENV['HOME'], "mnt", "usb", "PrelingerPane") if RUBY_PLATFORM =~ /(armv6l-linux-eabi)/i
      loc
    end

    def to_save
      @to_save
    end

    def url_to_filename(url)
      parts = URI.split url
      until parts.last do
        parts.pop
      end
      parts.last.split('/').last
    end

    #def url
    #  @url
    #end
  end
end