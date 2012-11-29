require 'spec_helper'

module Prelingerpane
  describe Prelingerpane do
    describe "#get_extension" do
      Prelingerpane::preferred_formats.each do |format|
        it "should return #{Prelingerpane::extension_hash[format]}" do
          Prelingerpane::get_extension(format).should == Prelingerpane::extension_hash[format]
        end
      end
    end

    describe "#best_format" do
      before(:all) do
        @doc = { 'format' => ["512Kb MPEG4", "Animated GIF", "Archive BitTorrent", "HiRes MPEG4", "MPEG2", "Metadata", "Ogg Video", "Thumbnail"] }
      end

      ["512Kb MPEG4", "Ogg Video", "MPEG2", "HiRes MPEG4", "Animated GIF", "Thumbnail"].each do |format|
        it "should return #{format}" do
          doc = { 'format' => [format, "Metadata"] }
          Prelingerpane::best_format(doc['format']).should == format
        end
      end
    end

    describe "#create_url" do
      it "should build a url to the file to be downloaded" do
        doc       = { 'identifier' => 'EatforHe1954' }
        extension = '_512kb.mp4'
        Prelingerpane::create_url(doc, extension).should == %q{http://archive.org/download/EatforHe1954/EatforHe1954_512kb.mp4}
      end
    end

    describe "#display_metadata" do
      Prelingerpane::metadata_to_show.each do |metadata|
        it "should display the #{metadata}" do
          output = StringIO.new('')
          doc = {'title' => 'General Health Habits', 'description' => 'Personal hygiene, 1920s-style.',
                 'creator' => ["Unknown"], 'format' => Prelingerpane::preferred_formats}
          extension = '_512kb.mp4'
          Prelingerpane::display_metadata(doc, extension, output)
          output.string.should match /#{doc[metadata]}/
        end
      end
    end
  end
end