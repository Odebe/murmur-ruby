# frozen_string_literal: true

module Proto
  class Decoder < GenericDecoder
    def send_message(msg)
      body = msg.is_a?(Mumble::UDPTunnel) ? msg.packet : msg.encode

      raw_msg =
        [
          [Dicts.find_type(msg.class)].pack('n'),
          [body.size].pack('N'),
          body
        ].join

      write raw_msg
      flush
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
        Dicts.find_class(type).decode(body)
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

    def flush
      @stream.flush
    end

    def write(body)
      @stream.write(body)
    end

    def read(size)
      @stream.read(size) or @stream.eof!
    end
  end
end
