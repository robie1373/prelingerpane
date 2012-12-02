module Prelingerpane
  class VideoPlayer
    def initialize(url)
      @url = url
    end

    def play(url)
      raspberypi_play(url) if RUBY_PLATFORM =~ /(armv6l-linux-eabi)/i
      osx_play(url) if RUBY_PLATFORM =~ /(darwin)/i
    end

    def osx_play(url)
      Thread.new do
        `vlc #{url}`
      end
    end

    def raspberypi_play(url)
      Thread.new do
        `omxplayer #{url}`
      end
    end

    def url
      @url
    end
  end
end