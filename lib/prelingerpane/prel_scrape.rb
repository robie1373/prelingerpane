require 'faraday'
require 'faraday_middleware'
require 'uri'

module Prelingerpane
  class PrelScrape
    include URI
    @rows = '6'

    def initialize(url = 'http://archive.org')
      @conn = Faraday.new(:url => url) do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.use FaradayMiddleware::FollowRedirects, limit: 3
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    def vid_download_conn(url = 'http://archive.org')
      Faraday.new(:url => url) do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.use FaradayMiddleware::FollowRedirects, limit: 3
        faraday.adapter :net_http
      end
    end

    def search_results(suffix = search_suffix, query = "date:[#{wayback_date}]")
      response = conn.get suffix, { :q      => query,
                                    :fl     => 'title',
                                    :sort   => "avg_rating desc",
                                    :rows   => '6',
                                    :page   => '1',
                                    :output => 'json' }

      response.body
    end

    def video(url, name)
      host   = URI.parse(url).host
      suffix = URI.parse(url).path
      video  = vid_download_conn("http://#{host}").get suffix
      #file_path = "#{name}_512kb.mp4"
      File.open(name, 'wb') { |f| f.write video.body }
    end

    def get_real_url(url)
      p url
      host = "http://#{URI.parse(url).host}"
      p host
      suffix = URI.parse(url).path
      parts  = suffix.split("/")
      parts.delete_at(-1)
      suffix = parts.join("/")
      p suffix
      downloads_url = URI.join(host, suffix).to_s
      #conn = Faraday.new(:url => host) do |faraday|
      #  faraday.request :url_encoded
      #  faraday.response :logger
      #  faraday.adapter Faraday.default_adapter
      #end
      response      = @conn.get "/download/Evolution_of_Man/"
      response.body
    end

=begin
    require 'net/http'
    def videonethttp(url, name)
      host = URI.parse(url).host
      suffix = URI.parse(url).path

      Net::HTTP.start(host) do |http|
        resp = http.get(suffix)
        open(name, "wb") do |file|
          file.write(resp.body)
        end
      end
      puts "Done."
    end
=end
=begin
    require 'open-uri'
    def video_open_uri(url,name)
      open(name, 'wb') do |fo|
        fo.print open(url).read
      end
    end
=end

    def search_suffix
      '/advancedsearch.php'
    end

    private
    def conn
      @conn
    end

    def wayback_date
      d               = DateTime.now
      year            = d.year - 60
      calculated_date = "#{year}-#{d.month}-#{d.day}"
      p calculated_date
      calculated_date
    end
  end
end