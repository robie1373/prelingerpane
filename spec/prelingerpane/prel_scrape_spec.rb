require_relative '../spec_helper'

module Prelingerpane
  describe PrelScrape do
    before(:each) do
      @scraper = PrelScrape.new
      @url = %q{http://archive.org/download/Evolution_of_Man/Evolution_of_Man_3mb.ogv}
      @tag = %q{<a href="6027_Evolution_of_Man_01_13_09_17_3mb.ogv">6027_Evolution_of_Man_01_13_09_17_3mb.ogv</a>}
    end
    describe "#search_results" do

      it "gets search results from archive.org" do

        suffix = @scraper.search_suffix
        query = %q{collection:"prelinger" } + %Q{title:"Health: "}
        @scraper.search_results(suffix, query).should match %r{title.+Health.+,}
      end
    end

    describe "#extract_path_from_tag" do
      it "pulls the real path out of the <a href=> tag" do
        @scraper.extract_path_from_tag(@tag).should == "6027_Evolution_of_Man_01_13_09_17_3mb.ogv"
      end
    end

    describe "#get_response_body" do
      it "returns the html page containing links to the files" do
        @scraper.get_response_body(@url).should match %r{\<html\>.+}
      end
    end

    describe "#parse_html_for_links" do
      it "returns an array of <a href=''> tags" do
        body = "<html>\r\n<head><title>Index of /1/items/Evolution_of_Man/</title></head>\r\n<body bgcolor=\"white\">\r\n<h1>Index of /1/items/Evolution_of_Man/</h1><hr><pre><a href=\"../\">../</a>\r\n<a href=\"Evolution_of_Man.thumbs/\">Evolution_of_Man.thumbs/</a>                           04-May-2012 16:24                   -\r\n<a href=\"6027_Evolution_of_Man_01_13_09_17_3mb.gif\">6027_Evolution_of_Man_01_13_09_17_3mb.gif</a>          04-May-2012 16:19              261433\r\n<a href=\"6027_Evolution_of_Man_01_13_09_17_3mb.mp4\">6027_Evolution_of_Man_01_13_09_17_3mb.mp4</a>          04-May-2012 16:10           255729461\r\n<a href=\"6027_Evolution_of_Man_01_13_09_17_3mb.ogv\">6027_Evolution_of_Man_01_13_09_17_3mb.ogv</a>          04-May-2012 16:58            48039374\r\n<a href=\"Evolution_of_Man_archive.torrent\">Evolution_of_Man_archive.torrent</a>                   28-Jun-2012 20:37               12953\r\n<a href=\"Evolution_of_Man_files.xml\">Evolution_of_Man_files.xml</a>                         28-Jun-2012 20:37               11121\r\n<a href=\"Evolution_of_Man_meta.xml\">Evolution_of_Man_meta.xml</a>                          04-May-2012 16:59                 464\r\n<a href=\"Evolution_of_Man_reviews.xml\">Evolution_of_Man_reviews.xml</a>                       29-Apr-2012 00:56                 790\r\n</pre><hr></body>\r\n</html>\r\n"
        @scraper.parse_html_for_links(body).length.should == ['<a href=\"../\">../</a>', '<a href=\"Evolution_of_Man.thumbs/\">Evolution_of_Man.thumbs/</a>', '<a href=\"6027_Evolution_of_Man_01_13_09_17_3mb.gif\">6027_Evolution_of_Man_01_13_09_17_3mb.gif</a>', '<a href=\"6027_Evolution_of_Man_01_13_09_17_3mb.mp4\">6027_Evolution_of_Man_01_13_09_17_3mb.mp4</a>', '<a href=\"6027_Evolution_of_Man_01_13_09_17_3mb.ogv\">6027_Evolution_of_Man_01_13_09_17_3mb.ogv</a>', '<a href=\"Evolution_of_Man_archive.torrent\">Evolution_of_Man_archive.torrent</a>', '<a href=\"Evolution_of_Man_files.xml\">Evolution_of_Man_files.xml</a>', '<a href=\"Evolution_of_Man_meta.xml\">Evolution_of_Man_meta.xml</a>', '<a href=\"Evolution_of_Man_reviews.xml\">Evolution_of_Man_reviews.xml</a>'].length
      end
    end

    describe "#get_real_url" do
      it "finds the real, wacky, unpredictable URL from archive.org" do
        #pending("work up motivation to use nokogiri to parse the body for URLs")
        @scraper.get_real_url(@url).should match %r{http://archive\.org/download/Evolution_of_Man/6027_Evolution_of_Man_01_13_09_17_3mb\.ogv}
      end
    end
  end
end