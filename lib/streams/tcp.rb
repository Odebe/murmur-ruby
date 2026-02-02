# frozen_string_literal: true

module Streams
  class Tcp < Generic
    wrap_nonblock(:read_nonblock, as: :read_nonblock)
    wrap_nonblock(:write_nonblock, as: :write_nonblock)

    def receive(*args)
      super(*args) or @io.eof!
    end

    def send(*args)
      super(*args)

      @io.flush
    end
  end
end
