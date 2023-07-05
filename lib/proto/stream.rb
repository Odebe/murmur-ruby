# frozen_string_literal: true

require 'async/io/protocol/generic'

module Proto
  class Stream < Async::IO::Protocol::Generic
    def closed?
      @stream.closed?
    end

    # TODO: write in one call
    def send_message(msg)
      body =
        if msg.is_a? ::Proto::Mumble::UDPTunnel
          msg.packet
        else
          msg.encode
        end

      raw_msg =
        [
          [Dicts::CLASS_TO_TYPE[msg.class]].pack('n'),
          [body.size].pack('N'),
          body
        ].join('')

      write raw_msg
    end

    def read_message
      type = read_type
      len  = read_length
      body = read_body(len)

      # avoiding UdpTunnel message parsing
      # cuz message body is literally voice packet and not protobuf message
      if type == 1
        Mumble::UDPTunnel.new(packet: body)
      else
        Dicts::TYPE_TO_CLASS[type].decode(body)
      end
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
