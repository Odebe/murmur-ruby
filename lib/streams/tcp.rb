# frozen_string_literal: true

module Streams
  class Tcp < Generic
    def initialize(io)
      super

      @buffered_io = IO::Stream::Buffered.wrap(@io)
    end

    def receive(*args)
      @buffered_io.read(*args)
    end

    def send(*args)
      @buffered_io.write(*args, flush: true)
    end
  end
end
