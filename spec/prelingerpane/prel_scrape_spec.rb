require_relative '../spec_helper'

module Prelingerpane
  describe PrelScrape do
    before(:each) do
      @scraper = PrelScrape.new
    end
    describe "#search_results" do

      it "gets search results from archive.org" do

        suffix = @scraper.search_suffix
        query  = %q{collection:"prelinger" } + %Q{title:"Health: "}
        @scraper.search_results(suffix, query).should match %r{title.+Health.+,}
      end
    end

    describe "#get_real_url" do

      it "finds the real, wacky, unpredictable URL from archive.org" do
        pending("work up motivation to use nokogiri to parse the body for URLs")
        url = %q{http://archive.org/download/Evolution_of_Man/Evolution_of_Man_3mb.ogv}
        @scraper.get_real_url(url).should == %r{http://.+/Evolution_of_Man/6027_Evolution_of_Man_01_13_09_17_3mb.ogv}
      end
    end
  end
end