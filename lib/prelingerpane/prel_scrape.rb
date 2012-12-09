require 'faraday'
require 'faraday_middleware'
require 'uri'
require 'nokogiri'

module Prelingerpane
  class PrelScrape
    include URI
    @rows       = '25'
    @video_path = File.join("public", "video")

    def initialize(url = 'http://archive.org')
      @conn = conn
      #    Faraday.new(:url => url) do |faraday|
      #  faraday.request :multipart
      #  faraday.request :url_encoded
      #  faraday.use FaradayMiddleware::FollowRedirects, limit: 3
      #  faraday.response :logger
      #  faraday.adapter Faraday.default_adapter
      #end
    end

    def conn(url = 'http://archive.org')
      Faraday.new(:url => url) do |faraday|
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
      response = catch_garbage do
        conn.get suffix, { :q      => query,
                           :fl     => 'title',
                           :sort   => "avg_rating desc",
                           :rows   => @rows,
                           :page   => '1',
                           :output => 'json' }
      end
      begin
        response.body
      rescue NoMethodError
        "No Data was received from archive.org. Are you online?"
      end
    end

    def video(url, name, path = @video_path)
      real_url     = get_real_url url
      host, suffix = break_url(real_url)
      video        = catch_garbage do
        vid_download_conn("http://#{host}").get suffix
      end
      save_path    = File.join(path, name)
      File.open(save_path, 'wb') { |f| f.write video.body }
    end

    def break_url(url)
      host   = URI.parse(url).host
      suffix = URI.parse(url).path
      return host, suffix
    end

    def get_real_url(url)
      body  = get_response_body(url)
      links = parse_html_for_links body
      link  = links.keep_if { |i| i.match /\.ogv/ }.first
      path  = extract_path_from_tag link

      host, suffix       = break_url(url)
      intermediate_paths = suffix.split('/')

      [0, -1].each do |index|
        intermediate_paths.delete_at(index)
      end

      intermediate_path = intermediate_paths.join('/')
      "http://#{host}/#{intermediate_path}/#{path}"
    end

    def get_response_body(url)
      host   = "http://#{URI.parse(url).host}"
      suffix = URI.parse(url).path
      parts  = suffix.split("/")
      parts.delete_at(-1)
      suffix        = parts.join("/")
      downloads_url = URI.join(host, suffix).to_s
      response      = catch_garbage do
        conn.get downloads_url
      end
      response.body
    end

    def catch_garbage
      old_stdout = $stdout
      $stdout    = StringIO.new
      val        = yield
    ensure
      $stdout = old_stdout
      return val
    end

    def parse_html_for_links(body)
      html  = Nokogiri::HTML(body)
      links = []
      html.xpath("//a").map { |i| links << i.to_s }
      links
    end

    def extract_path_from_tag(tag)
      (tag.match /\<a href=".+"\>(.+)\<\/a\>/)[1]
    end

    def search_suffix
      '/advancedsearch.php'
    end

    private
    #def conn
    #  @conn
    #end

    def wayback_date
      d               = DateTime.now
      year            = d.year - 60
      calculated_date = "#{year}-#{d.month}-#{d.day}"
      p calculated_date
      calculated_date
    end
  end
end