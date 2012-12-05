module Prelingerpane
  class VideoPlayer
    def initialize(url)
      @url = url
    end

    def play
      raspberypi_play if RUBY_PLATFORM =~ /(armv6l-linux-eabi)/i
      osx_play if RUBY_PLATFORM =~ /(darwin)/i
    end

    def osx_play
      Thread.new do
        `/Applications/VLC.app/Contents/MacOS/VLC #{url}`
      end
    end

    def raspberypi_play
      Thread.new do
        `omxplayer #{url} & fbset -depth 8 && fbset -depth 16`
      end
    end

    def url
      @url
    end
  end
end