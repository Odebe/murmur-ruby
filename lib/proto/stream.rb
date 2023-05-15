# frozen_string_literal: true

require 'async/io/protocol/generic'

module Proto
  class Stream < Async::IO::Protocol::Generic
    def send_message(msg)
      body = msg.encode

      write_type msg.class
      write_length body
      write body
    end

    def read_message
      type = read_type
      len  = read_length
      body = read_body(len)

      Dicts::TYPE_TO_CLASS[type].decode(body)
    end

    private

    def read_type
      read(2).unpack1('n')
    end

    def read_length
      read(4).unpack1('N')
    end

    def read_body(len)
      read(len)
    end

    def write_type(klass)
      write [Dicts::CLASS_TO_TYPE[klass]].pack('n')
    end

    def write_length(body)
      write [body.size].pack('N')
    end

    def write(body)
      @stream.write(body)
    end

    def read(size)
      @stream.read(size) or @stream.eof!
    end
  end
end
