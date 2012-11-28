require 'faraday'

module Prelingerpane
  class PrelScrape
    def initialize(url = 'http://archive.org')
      @conn = Faraday.new(:url => url) do |faraday|
        faraday.request :url_encoded
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    #q=createdate%3 A%5 B1950+TO+1960%5 D
    #&fl%5 B%5 D=title
    #&sort%5 B%5 D=avg_rating+desc
    #&sort%5 B%5 D=
    #&sort%5 B%5 D=
    #&rows=10
    #&page=1
    #&output=json

    def date
      d = DateTime.now
      year = d.year - 60
      calculated_date = "#{year}-11-30"
      p calculated_date
      calculated_date
    end

    def body(suffix = '/advancedsearch.php', query = "date:[#{date}]")
      response = conn.get suffix, { :q => query,
                                              :fl => 'title',
                                              :sort => "avg_rating desc",
                                              :rows => '3',
                                              :page => '1',
                                              :output => 'json' }

      response.body
    end

    def conn
      @conn
    end
  end
end